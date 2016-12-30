//
//  ViewController.m
//  AdactiveMapiOS
//
//  Created by Aiza Simbra on 12/13/16.
//  Copyright © 2016 Aiza Simbra. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <AdsumIOSAPI/ADSumMapViewController.h>

@interface ViewController ()<ADSumMapViewControllerDelegate, CLLocationManagerDelegate>{
    CLLocationManager *_compassManager;
    CLLocation        *_previousLocation;
}

@property (nonatomic, strong)ADSumMapViewController *adSumMapViewController;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self initializeMap];
    [self initializeCompass];
    
}

#pragma mark - Map

- (void)initializeMap{
    self.adSumMapViewController = [[ADSumMapViewController alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.adSumMapViewController.delegate = self;
    self.adSumMapViewController.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.adSumMapViewController.view];
    
    [self.adSumMapViewController update];
}

- (void)initializeCompass{
    _compassManager = [[CLLocationManager alloc] init];
    [_compassManager setDelegate:self];
    _compassManager.headingFilter = kCLHeadingFilterNone;
    _compassManager.activityType = CLActivityTypeFitness;
    [_compassManager startUpdatingHeading];
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading{
    if (newHeading.headingAccuracy < 0)
        return;
    
    CLLocationDirection heading = (newHeading.trueHeading > 0) ? newHeading.trueHeading : newHeading.magneticHeading;
    
    [self.adSumMapViewController rotateCameraToBearing:heading];
}

#pragma mark - AdSumMapViewControllerDelegate

- (void)dataDidFinishUpdating:(id)adSumViewController
{
    NSLog(@"[ADS] dataDidFinishUpdating");
    [self.adSumMapViewController start];
}

-(void)dataDidFinishUpdating:(id)adSumViewController withError:(NSError *)error
{
    //Check if there are map data allready downloaded
    if([self.adSumMapViewController isMapDataAvailable]){
        // You can start the map since map data are present
        NSLog(@"[ADS] dataDidFinishUpdating -- MAP DATA AVAILABLE");
        [self.adSumMapViewController start];
    }else{
        NSLog(@"[ADS] dataDidFinishUpdating -- MAP DATA NOT AVAILABLE");
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"update finished with errors"
                                                          message:nil
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        [message show];
    }
}

- (void)mapDidFinishLoading:(id)adSumViewController
{
    NSLog(@"[ADS] mapDidFinishLoading");
    
    [self.adSumMapViewController setCameraMode:CameraMode_FULL/*CameraMode_ORTHO*/];
    
    //create path
    AdsumCorePath *path = [self.adSumMapViewController getPathObject];
    [path setPatternOffsetWithX:0 Y:0 Z:7];
    [path setMarkerSizeWithX:8 Y:8];
    [path setMarkerMode:ROTATE_TO_CAMERA];
    [path setSpace:5];
    
    //set start point
    long currentFloorId = [self.adSumMapViewController getCurrentFloor];
    NSLog(@"[ADS] start current floor id: %ld",currentFloorId);
    [self.adSumMapViewController setCurrent3DPosition:100 y:50 floor:currentFloorId];
    
    //draw path
    [self.adSumMapViewController drawPathToPlace:27043];
   
    //center and zoom
    [self.adSumMapViewController centerOnPlace:27050 distance:500 animationTime:5];
    
}

- (void)adSumViewController:(id)adSumViewController OnPOIClicked:(NSArray *)poiIDs placeId:(long)placeId
{
    NSLog(@"[ADS] OnPOIClicked poIDs: %@ placeId: %ld",poiIDs,placeId);
    
    //Unlight all the POIs previously highlighted
    [self.adSumMapViewController unLightAll];
    //Center the camera on the place the user clicked
    [self.adSumMapViewController centerOnPlace:placeId];
    //HighLight the first POI linked to the place the user clicked
    [self.adSumMapViewController highLightPlace:placeId color:[UIColor greenColor]];
}

- (void)adSumViewController:(id)adSumViewController OnFloorChanged:(long)floorId{
    NSLog(@"[ADS] onFloorChanged: %ld",floorId);
    
}

- (void)adSumViewController:(id)adSumViewController OnFloorClicked:(long)floorId{
    NSLog(@"[ADS] OnFloorClicked: %ld",floorId);
}

- (void)adSumViewController:(id)adSumViewController OnBuildingClicked:(long)buildingId{
    NSLog(@"[ADS] OnBuildingClicked: %ld",buildingId);
}

#pragma mark -

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
