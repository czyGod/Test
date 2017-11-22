//
//  CZYSportViewController.m
//  酷跑
//
//  Created by hzxsdz030 on 15/12/10.
//  Copyright © 2015年 hzxsdz030. All rights reserved.
//

#import "CZYSportViewController.h"
#import "BMapKit.h"
#import "AFHTTPRequestOperationManager.h"
#import "CZYUserInfo.h"
#import "CZYSport.h"
typedef enum {
    TrailStart = 1,
    TrailEnd
} Trail;
#define BMKSPAN 0.002
@interface CZYSportViewController ()<BMKMapViewDelegate,BMKLocationServiceDelegate>
//地图View
@property (nonatomic, strong) BMKMapView *mapView;
//地图位置服务
@property (nonatomic, strong) BMKLocationService *locationService;
//用户是否画轨迹线
@property (nonatomic, assign) Trail trail;
//起点和终点的大头针
@property (nonatomic, strong) BMKPointAnnotation *startAnnotation;
@property (nonatomic, strong) BMKPointAnnotation *endAnnotation;
/**保存位置的数组*/
@property (nonatomic, strong) NSMutableArray *locationArr;
//开始跑步按钮
@property (weak, nonatomic) IBOutlet UIButton *startSportBtn;
@property (weak, nonatomic) IBOutlet UIButton *pauseSportBtn;
/**点击完成跳出该视图*/
@property (weak, nonatomic) IBOutlet UIView *sportCompleteView;
@property (weak, nonatomic) IBOutlet UIImageView *backGroundImageView;

/**记录上次位置*/
@property (nonatomic, strong) CLLocation *preLocation;
@property (nonatomic, assign) NSTimeInterval sumTime;
@property (nonatomic, assign) CGFloat sumDistance;
@property (nonatomic, assign) CGFloat sumHeat;
/**地图上的线*/
@property (nonatomic, strong) BMKPolyline *polyline;
/**继续和完成视图*/
@property (weak, nonatomic) IBOutlet UIView *pauseView;
/**运动种类*/
@property (nonatomic, assign) enum SportModel chooseSportModel;

@end
@implementation CZYSportViewController
- (NSMutableArray *)locationArr {
    if (!_locationArr) {
        _locationArr = [NSMutableArray array];
    }
    return _locationArr;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //初始化运动记录
    self.sumDistance = 0.0;
    self.sumHeat = 0.0;
    self.sumTime = 0.0;
    
    //初始化mapView
    [self setupMapView];
    [self initBMLocationSerVice];
    self.trail = TrailEnd;
    //添加轻扫手势
    UISwipeGestureRecognizer *swipeGR = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(pauseBtnSwipe)];
    swipeGR.direction = UISwipeGestureRecognizerDirectionDown;
    [self.pauseSportBtn addGestureRecognizer:swipeGR];
}

- (void)pauseBtnSwipe {
    self.pauseSportBtn.hidden = YES;
    self.pauseView.hidden = NO;
    [self.locationService stopUserLocationService];
}
//百度地图的初始化
- (void)setupMapView {
    self.mapView = [[BMKMapView alloc] initWithFrame:self.view.bounds];
    [self.view insertSubview:self.mapView atIndex:0];
    self.mapView.delegate = self;
    //mapView的属性
    self.mapView.mapType = BMKMapTypeStandard;
    //显示定位图层
    self.mapView.showsUserLocation = YES;
    self.mapView.userTrackingMode = BMKUserTrackingModeNone;
    self.mapView.rotateEnabled = YES;
    self.mapView.showMapScaleBar = YES;
    //比例尺的位置
    self.mapView.mapScaleBarPosition = CGPointMake(self.view.frame.size.width - 50, self.view.frame.size.height - 50);
    //定位图层，自定义样式参数
    BMKLocationViewDisplayParam *displayParam = [[BMKLocationViewDisplayParam alloc] init];
    displayParam.isAccuracyCircleShow = NO;
    displayParam.isRotateAngleValid = YES;
    displayParam.locationViewOffsetX = 0;
    displayParam.locationViewOffsetY = 0;
    [self.mapView updateLocationViewWithParam:displayParam];
    
}
//初始化地图位置服务
- (void)initBMLocationSerVice {
    self.locationService = [[BMKLocationService alloc] init];
    [BMKLocationService setLocationDistanceFilter:5];
    [BMKLocationService setLocationDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
    self.locationService.delegate = self;
}

#pragma mark - BMKLocationServiceDelegate
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation {
    CGFloat lon = userLocation.location.coordinate.longitude;
    CGFloat lat = userLocation.location.coordinate.latitude;
    MYLog(@"用户位置变化:%lf:%lf",lon,lat);
    [self.mapView updateLocationData:userLocation];
    //以用户目前位置为中心点，并设置扇区范围
    if (self.trail == TrailEnd) {
        BMKCoordinateRegion adjustRegion = [self.mapView regionThatFits:BMKCoordinateRegionMake(userLocation.location.coordinate, BMKCoordinateSpanMake(BMKSPAN, BMKSPAN))];
        [self.mapView setRegion:adjustRegion animated:YES];
    }
    if (userLocation.location.horizontalAccuracy > kCLLocationAccuracyNearestTenMeters) {
        return;
    }
    if (self.trail == TrailStart) {
        //开始跟踪用户
        [self startTrailRouterWithUserLocation:userLocation];
        //用户当前位置为地图中心点
        [self.mapView setRegion:BMKCoordinateRegionMake(userLocation.location.coordinate, BMKCoordinateSpanMake(BMKSPAN, BMKSPAN)) animated:YES];
    }
}

/**用户方向改变后调用*/
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation {
    //动态更新我的位置数据
    [self.mapView updateLocationData:userLocation];
}
- (void)startTrailRouterWithUserLocation:(BMKUserLocation *)userLocation {
    if (self.preLocation) {
//        NSTimeInterval dtime = [userLocation.location.timestamp timeIntervalSinceDate:self.preLocation.timestamp];
        CGFloat distance = [userLocation.location distanceFromLocation:self.preLocation];
        
        if (distance < 5) {
            return;
        }
        self.sumDistance += distance;
    }
    [self.locationArr addObject:userLocation.location];
    self.preLocation = userLocation.location;
    //画图
    [self drawWalkPolyline];
}

- (void)drawWalkPolyline {
    NSInteger count = self.locationArr.count;
        BMKMapPoint *tempPoints = new BMKMapPoint[count];
    [self.locationArr enumerateObjectsUsingBlock:^(CLLocation  *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        BMKMapPoint point = BMKMapPointForCoordinate(obj.coordinate);
        
    }];
    self.polyline = [BMKPolyline polylineWithPoints:tempPoints count:count];
    //向地图添加路径
    if (self.polyline) {
        [self.mapView addOverlay:self.polyline];
    }
    //释放内存
//    free(tempPoints);
    
}

#pragma mark - BMKMapViewDelegate
/** 遮盖的显示 */
- (BMKOverlayView*) mapView:(BMKMapView *)mapView viewForOverlay:(id<BMKOverlay>)overlay
{
    if ([overlay isKindOfClass:[BMKPolyline class]]) {
        BMKPolylineView *polyLineView = [[BMKPolylineView alloc]initWithOverlay:overlay];
        polyLineView.fillColor = [[UIColor clearColor]colorWithAlphaComponent:0.7];
        polyLineView.strokeColor = [[UIColor greenColor] colorWithAlphaComponent:0.7];
        polyLineView.lineWidth = 5.0;
        return polyLineView;
    }
    return nil;
}
/**添加大头针方法*/
- (BMKPointAnnotation *)createPointWithLocation:(CLLocation *)location title:(NSString *)title {
    BMKPointAnnotation *point = [[BMKPointAnnotation alloc] init];
    point.coordinate = location.coordinate;
    point.title = title;
    [self.mapView addAnnotation:point];
    return point;
}

/**显示大头针*/
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id<BMKAnnotation>)annotation {
    if ([annotation isKindOfClass:[BMKPointAnnotation class]]) {
        static NSString *annotationStr = @"myAnnotation";
        BMKPinAnnotationView *annotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationStr];
        //如果有起点，就设置终点图片，否则设置起点图片
        if (self.startAnnotation) {
            annotationView.image = [UIImage imageNamed:@"定位终点"];
        }else {
            annotationView.image = [UIImage imageNamed:@"定位起点"];
        }
        //从天而降的效果
        annotationView.animatesDrop = YES;
        annotationView.draggable = NO;
        return annotationView;
    }
    return nil;
}


/**
 *  清空数组以及地图上的轨迹
 */
- (void)clean
{
    // 清空状态信息
    self.sumDistance = 0.0;
    self.sumHeat = 0.0;
    self.sumTime  = 0.0;
    //清空数组
    [self.locationArr removeAllObjects];
    
    //清屏，移除标注点
    if (self.startAnnotation) {
        [self.mapView removeAnnotation:self.startAnnotation];
        self.startAnnotation = nil;
    }
    if (self.endAnnotation) {
        [self.mapView removeAnnotation:self.endAnnotation];
        self.endAnnotation = nil;
    }
    if (self.polyline) {
        [self.mapView removeOverlay:self.polyline];
        self.polyline = nil;
    }
}

/**
 *  运动完成后 根据polyline设置地图范围
 *  根据点求出最大的x和最小的x  以及最大的y和最小的y 从而计算出范围
 *  @param polyLine
 */
- (void)mapViewFitPolyLineNew:(BMKPolyline *) polyLine {
    CGFloat ltX, ltY, rbX, rbY;
    if (polyLine.pointCount < 1) {
        return;
    }
    BMKMapPoint pt = polyLine.points[0];
    ltX = pt.x, ltY = pt.y;
    rbX = pt.x, rbY = pt.y;
    for (int i = 1; i < polyLine.pointCount; i++) {
        BMKMapPoint pt = polyLine.points[i];
        if (pt.x < ltX) {
            ltX = pt.x;
        }
        if (pt.x > rbX) {
            rbX = pt.x;
        }
        if (pt.y > ltY) {
            ltY = pt.y;
        }
        if (pt.y < rbY) {
            rbY = pt.y;
        }
    }
    BMKMapRect rect;
    rect.origin = BMKMapPointMake(ltX-40 , ltY-60);
    rect.size = BMKMapSizeMake((rbX - ltX)+80, (rbY - ltY)+120);
    [self.mapView setVisibleMapRect:rect];
    
}

#pragma mark - start
/**开始跑步*/
- (IBAction)startSport:(UIButton *)sender {
    self.trail = TrailStart;
    self.startAnnotation = [self createPointWithLocation:self.locationService.userLocation.location title:@"起点"];
    self.startSportBtn.hidden = YES;
    self.pauseSportBtn.hidden = NO;
    
}

/**下拉暂停*/
- (IBAction)pauseSport:(UIButton *)sender {
    [self.locationService stopUserLocationService];
    self.pauseSportBtn.hidden = YES;
    self.startSportBtn.hidden = NO;
}

/**继续跑步*/
- (IBAction)continueSport:(UIButton *)sender {
    [self.locationService startUserLocationService];
    self.pauseView.hidden = YES;
    self.pauseSportBtn.hidden = NO;
    
    
}
/**结束跑步*/
- (IBAction)completeSport:(UIButton *)sender {
    //停止定位
    [self stopTrack];
    self.pauseView.hidden = YES;
    self.pauseSportBtn.hidden = YES;
    
    [self mapViewFitPolyLineNew:self.polyline];
    /* 计算本次运动的数据 */
    CLLocation  *firstLoc = self.locationArr.firstObject;
    CLLocation  *lastLoc = self.locationArr.lastObject;
    /* 运动时间  秒 */
    double st = ([lastLoc.timestamp timeIntervalSince1970] - [firstLoc.timestamp timeIntervalSince1970]);
    self.sumTime = st;
    self.sumHeat = (st/3600.0)*600.0;
}

/**停止定位服务*/
- (void)stopTrack {
    //1.设置轨迹记录状态为：结束
    self.trail = TrailEnd;
    //2.关闭定位服务
    [self.locationService stopUserLocationService];
    //3.添加终点旗帜
    if (self.startAnnotation) {
        self.endAnnotation = [self createPointWithLocation:self.preLocation title:@"终点"];
    }
    
}
/**取消本次运动*/
- (IBAction)cancelSport:(UIButton *)sender {
    /**回到初始状态*/
    [self clean];
    self.sportCompleteView.hidden = YES;
    self.backGroundImageView.hidden = YES;
    self.startSportBtn.hidden = NO;
    BMKCoordinateRegion adjustRegion = [self.mapView regionThatFits:BMKCoordinateRegionMake(self.locationService.userLocation.location.coordinate, BMKCoordinateSpanMake(BMKSPAN, BMKSPAN))];
    [self.mapView setRegion:adjustRegion animated:YES];
}

/**保存*/
- (IBAction)saveMapImageToPhoto:(UIButton *)sender {
    MYLog(@"保存数据到相册中");
    /**将数据存到webServer中*/
    [self saveSportDataToServer];
    /**结束本次运动*/
    [self cancelSport:nil];
}

/**本地分享*/
- (IBAction)sharedSportRecordToServer:(UIButton *)sender {
    
    
}

/**新浪分享*/
- (IBAction)sharedSportRecordToSina:(UIButton *)sender {
    /* 组装微博数据 运动距离 运动时长 运动消耗能量 */
    NSString *statusStr = [NSString stringWithFormat:@"本地运动总距离:%.1lf米,运动总时间为:%.1lf秒,消耗热量%.4lf卡",self.sumDistance,self.sumTime,self.sumHeat];
    UIImage *image = [self.mapView takeSnapshot];
    AFHTTPRequestOperationManager *manager =
    [AFHTTPRequestOperationManager manager];
    NSString *url = @"https://upload.api.weibo.com/2/statuses/upload.json";
    NSMutableDictionary *parameters = [ NSMutableDictionary dictionary];
    parameters[@"access_token"] = [CZYUserInfo sharedCZYUserInfo].sinaToken;
    parameters[@"status"] = statusStr;
    if ([CZYUserInfo sharedCZYUserInfo].sinaLogin) {
        [manager POST:url parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            [formData appendPartWithFileData:UIImagePNGRepresentation(image) name:@"pic" fileName:@"运动记录.png" mimeType:@"image/jpeg"];
        } success:^(AFHTTPRequestOperation *operation, id responseObject) {
            MYLog(@"发布微博成功");
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            MYLog(@"发布微博失败");
        }];
    }else{
        MYLog(@"请使用新浪的第三方登录");
    }

}

/**保存数据到webServer*/
- (void)saveSportDataToServer {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *url = [NSString stringWithFormat:@"http://%@:8080/allRunServer/addSportData.jsp",CZYXMPPHOSTNAME];
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    CZYUserInfo *userInfo = [CZYUserInfo sharedCZYUserInfo];
    param[@"username"] = userInfo.username;
    param[@"md5password"] = userInfo.userpwd;
    param[@"sportType"] = @(self.chooseSportModel);
    CLLocation *firstLocation = [self.locationArr firstObject];
    CLLocation *lastLocation = [self.locationArr lastObject];
    NSString *dataStr = [NSString stringWithFormat:@"%lf|%lf|%lf@%lf|%lf|%lf",firstLocation.timestamp.timeIntervalSince1970,
                         firstLocation.coordinate.latitude,firstLocation.coordinate.longitude,lastLocation.timestamp.timeIntervalSince1970,lastLocation.coordinate.latitude,lastLocation.coordinate.longitude];
    param[@"data"] = dataStr;
    
    param[@"sportDistance"] = @(self.sumDistance);
    double sportTime = ([lastLocation.timestamp timeIntervalSince1970] - [firstLocation.timestamp timeIntervalSince1970]);
    param[@"sportHeat"] = @(self.sumHeat);
    param[@"sportTimeLen"] = @(sportTime);
    param[@"sportStartTime"] = @([firstLocation.timestamp timeIntervalSince1970]);
    MYLog(@"%@",dataStr);
    [manager POST:url parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        MYLog(@"sport---%@",responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        MYLog(@"请求失败,原因%@",error.userInfo);
    }];
}

/* 生成图片缩略图 */
- (UIImage *)thumbnailWithImage:(UIImage *)image size:(CGSize)asize

{
    UIImage *newimage;
    if (nil == image) {
        newimage = nil;
    }else{
        UIGraphicsBeginImageContext(asize);
        [image drawInRect:CGRectMake(0, 0, asize.width, asize.height)];
        newimage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return newimage;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
