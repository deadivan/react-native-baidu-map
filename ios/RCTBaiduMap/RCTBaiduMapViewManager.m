//
//  RCTBaiduMapViewManager.m
//  RCTBaiduMap
//
//  Created by lovebing on Aug 6, 2016.
//  Copyright © 2016 lovebing.org. All rights reserved.
//

#import "RCTBaiduMapViewManager.h"

@implementation RCTBaiduMapViewManager;

RCT_EXPORT_MODULE(RCTBaiduMapView)

RCT_EXPORT_VIEW_PROPERTY(mapType, int)
RCT_EXPORT_VIEW_PROPERTY(zoom, float)
RCT_EXPORT_VIEW_PROPERTY(trafficEnabled, BOOL)
RCT_EXPORT_VIEW_PROPERTY(baiduHeatMapEnabled, BOOL)
RCT_EXPORT_VIEW_PROPERTY(marker, NSDictionary*)
RCT_EXPORT_VIEW_PROPERTY(markers, NSArray*)

RCT_EXPORT_VIEW_PROPERTY(onChange, RCTBubblingEventBlock)

RCT_CUSTOM_VIEW_PROPERTY(center, CLLocationCoordinate2D, RCTBaiduMapView) {
    [view setCenterCoordinate:json ? [RCTConvert CLLocationCoordinate2D:json] : defaultView.centerCoordinate];
}




+(void)initSDK:(NSString*)key {

    BMKMapManager* _mapManager = [[BMKMapManager alloc]init];
    BOOL ret = [_mapManager start:key  generalDelegate:nil];
    if (!ret) {
        NSLog(@"manager start failed!");
    }

}

- (UIView *)view {
    RCTBaiduMapView* mapView = [[RCTBaiduMapView alloc] init];
    mapView.delegate = self;
    return mapView;
}

-(void)mapview:(BMKMapView *)mapView
 onDoubleClick:(CLLocationCoordinate2D)coordinate {
    NSLog(@"onDoubleClick");
    NSDictionary* event = @{
                            @"type": @"onMapDoubleClick",
                            @"params": @{
                                    @"latitude": @(coordinate.latitude),
                                    @"longitude": @(coordinate.longitude)
                                    }
                            };
    [self sendEvent:mapView params:event];
}

-(void)mapView:(BMKMapView *)mapView
onClickedMapBlank:(CLLocationCoordinate2D)coordinate {
    NSLog(@"onClickedMapBlank");
    NSDictionary* event = @{
                            @"type": @"onMapClick",
                            @"params": @{
                                    @"latitude": @(coordinate.latitude),
                                    @"longitude": @(coordinate.longitude)
                                    }
                            };
    [self sendEvent:mapView params:event];
}

-(void)mapViewDidFinishLoading:(BMKMapView *)mapView {
    mapView.buildingsEnabled =NO;
    mapView.rotateEnabled =NO;
    mapView.zoomEnabled =NO;
    mapView.overlookEnabled=YES;
    mapView.zoomEnabledWithTap=NO;
    mapView.overlooking = -45;
    NSDictionary* event = @{
                            @"type": @"onMapLoaded",
                            @"params": @{}
                            };
    [self sendEvent:mapView params:event];
}

-(void)mapView:(BMKMapView *)mapView
didSelectAnnotationView:(BMKAnnotationView *)view {

    NSDictionary* event = @{
                            @"type": @"onMarkerClick",
                            @"params": @{
                                    @"title": [[view annotation] title],
                                    @"position": @{
                                            @"latitude": @([[view annotation] coordinate].latitude),
                                            @"longitude": @([[view annotation] coordinate].longitude)
                                            }
                                    }
                            };
    [self sendEvent:mapView params:event];

    [view setSelected:NO];
}

- (void) mapView:(BMKMapView *)mapView
 onClickedMapPoi:(BMKMapPoi *)mapPoi {
    NSLog(@"onClickedMapPoi");
    NSDictionary* event = @{
                            @"type": @"onMapPoiClick",
                            @"params": @{
                                    @"name": mapPoi.text,
                                    @"uid": mapPoi.uid,
                                    @"latitude": @(mapPoi.pt.latitude),
                                    @"longitude": @(mapPoi.pt.longitude)
                                    }
                            };
    [self sendEvent:mapView params:event];
}

- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation {
    if ([annotation isKindOfClass:[BMKPointAnnotation class]]) {

        BMKPinAnnotationView *newAnnotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"myAnnotation"];
        newAnnotationView.frame = CGRectMake(0, 0, 200, 30);
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
        newAnnotationView.paopaoView = [[BMKActionPaopaoView alloc] initWithCustomView:view];

        UIImage * image = [UIImage imageNamed:@"icon-pin-340.png"];
        newAnnotationView.image = image;   //把大头针换成别的图片
        UILabel * labelNo = [[UILabel alloc]initWithFrame:CGRectMake(30, -2, 200, 30)];
        labelNo.text =[NSString stringWithFormat:@"%@",annotation.title];
        labelNo.textColor = [UIColor whiteColor];
        labelNo.backgroundColor = [UIColor clearColor];

        [newAnnotationView addSubview:labelNo];
        return newAnnotationView;

    }
    return nil;
}

-(void)mapStatusDidChanged: (BMKMapView *)mapView	 {
    NSLog(@"mapStatusDidChanged");
    CLLocationCoordinate2D targetGeoPt = [mapView getMapStatus].targetGeoPt;
    NSDictionary* event = @{
                            @"type": @"onMapStatusChange",
                            @"params": @{
                                    @"target": @{
                                            @"latitude": @(targetGeoPt.latitude),
                                            @"longitude": @(targetGeoPt.longitude)
                                            },
                                    @"zoom": @"",
                                    @"overlook": @""
                                    }
                            };
    [self sendEvent:mapView params:event];
}

-(void)sendEvent:(RCTBaiduMapView *) mapView params:(NSDictionary *) params {
    if (!mapView.onChange) {
        return;
    }
    mapView.onChange(params);
}

-(void)myAnnotationPressed:(UIButton *)btn
{
    NSLog(@"aaaaa");
}

-(void)myAnnotationPressedMapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation
{

}

@end
