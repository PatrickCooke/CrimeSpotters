//
//  ViewController.m
//  CrimeSpotters
//
//  Created by Patrick Cooke on 5/5/16.
//  Copyright © 2016 Patrick Cooke. All rights reserved.
//

#import "ViewController.h"
#import "Reachability.h"
#import "PoliceStations.h"
#import "LiquorStore.h"
#import "BarsRestaurants.h"
#import "MyPointAnnotation.h"
#import <MapKit/MapKit.h>

@interface ViewController ()

@property (nonatomic, strong)         NSString         *hostName;
@property (nonatomic, strong)         NSMutableArray   *policeArray;
@property (nonatomic, weak)  IBOutlet MKMapView        *mapView;
@property (nonatomic, strong)         NSMutableArray   *lStoreArray;
@property (nonatomic, strong)         NSMutableArray   *barsArray;
@property (nonatomic, strong)         NSMutableArray   *crimeArray;

@end

@implementation ViewController

#pragma mark - Global Variables

Reachability *hostReach;
Reachability *internetReach;
Reachability *wifiReach;
bool internetAvailable;
bool serverAvailable;
bool policePinsOff = true;
bool barPinsoff = true;
bool lStorePinsoff = true;


#pragma mark - Pull Police Data

- (void)getPoliceInfo {
    NSLog(@"GPI");
    if (serverAvailable) {
        NSLog(@"Server Available");
        NSURL *fileURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://%@/resource/3n6r-g9kp.json?$$app_token=bjp8KrRvAPtuf809u1UXnI0Z8", _hostName]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:fileURL];
        [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
        [request setTimeoutInterval:30.0];
        NSURLSession *session = [NSURLSession sharedSession];
        NSLog(@"URL searhing: %@",fileURL);
        [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            NSLog(@"Got Response");
            if (([data length] > 0) && (error == nil)) {
                NSJSONSerialization *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                //NSLog(@"Got jSON %@", json);
                [_policeArray removeAllObjects];
                NSArray *tempArray = (NSArray *)json;
                for (NSDictionary *station in tempArray) {
                    NSString *address = [station objectForKey:@"address_1"];
                    NSString *captain = [station objectForKey:@"captain"];
                    NSDictionary *coordDict = [station objectForKey:@"location"];
                    NSArray *coords = [coordDict objectForKey:@"coordinates"];
                    NSString *lat = coords[1];
                    NSString *lon = coords[0];
                    NSString *city = [station objectForKey:@"location_city"];
                    NSString *state = [station objectForKey:@"location_state"];
                    NSString *precint = [station objectForKey:@"precint"];
                    //NSLog(@" Address:%@, captain:%@ lat:%@ lon:%@ city:%@, state:%@, p:%@",address, captain, lat,lon, city, state, precint);
                    PoliceStations *newstation = [[PoliceStations alloc] initWithPAddress:address andCaptainName:captain andLatitude:lat andLongitude:lon andCity:city andState:state andPrecinct:precint];
                    [_policeArray addObject:newstation];
                }
                NSLog(@"Police records %li", _policeArray.count);
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"dataRcvMsg" object:nil];
                });
            }}] resume];
    }
}


#pragma mark - Liquor Store Data

- (void)getLiquorStoreInfo {
    if (serverAvailable) {
        NSLog(@"Server Available");
        NSURL *fileURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://%@/resource/djd8-sm8q.json", _hostName]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:fileURL];
        [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
        [request setTimeoutInterval:30.0];
        NSURLSession *session = [NSURLSession sharedSession];
        NSLog(@"URL searhing: %@",fileURL);
        [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            NSLog(@"Got Response");
            if (([data length] > 0) && (error == nil)) {
                NSJSONSerialization *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                //NSLog(@"Got jSON %@", json);
                [_lStoreArray removeAllObjects];
                NSArray *tempArray = (NSArray *)json;
                for (NSDictionary *store in tempArray) {
                    NSString *permittype = [store objectForKey:@"permit_type"];
                    NSString *name = [store objectForKey:@"name"];
                    NSDictionary *coordDict = [store objectForKey:@"full_address_value"];
                    NSArray *coords = [coordDict objectForKey:@"coordinates"];
                    NSString *lat = coords[1];
                    NSString *lon = coords[0];
                    NSString *street = [store objectForKey:@"full_address_value_address"];
                    NSString *city = [store objectForKey:@"full_address_value_city"];
                    NSString *zip = [store objectForKey:@"full_address_value_zip"];
                    NSString *active = [store objectForKey:@"active"];
                    //NSLog(@"permit - %@, name -  %@, lat:%@, lon:%@, street address %@, city %@, zip %@, active %@", permittype, name, lat, lon, street, city, zip, active);
                    
                    LiquorStore *newstore = [[LiquorStore alloc] initWithName:name andpermitType:permittype andLat:lat andlon:lon andaddress:street andcity:city andzip:zip andactive:active];
                    [_lStoreArray addObject:newstore];
                }
                NSMutableArray *discardedItems = [NSMutableArray array];
                
                for (LiquorStore *loc in _lStoreArray) {
                    if ([loc.permitType containsString:@"FOOD"]) [discardedItems addObject:loc];
                    if (loc.Lat == 0) [discardedItems addObject:loc];
                }
                
                [_lStoreArray removeObjectsInArray:discardedItems];
                NSLog(@"total liqour stores %li", _lStoreArray.count);
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"dataRcvMsg" object:nil];
                });
            }
          }
          ] resume];
    }
}

#pragma mark - Bars/Restaurants Data

- (void)getBarRestaurantsInfo {
    if (serverAvailable) {
        NSLog(@"Server Available");
        NSURL *fileURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://%@/resource/djd8-sm8q.json", _hostName]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:fileURL];
        [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
        [request setTimeoutInterval:30.0];
        NSURLSession *session = [NSURLSession sharedSession];
        NSLog(@"URL searhing: %@",fileURL);
        [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            NSLog(@"Got Response");
            if (([data length] > 0) && (error == nil)) {
                NSJSONSerialization *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                //NSLog(@"Got jSON %@", json);
                [_barsArray removeAllObjects];
                NSArray *tempArray = (NSArray *)json;
                for (NSDictionary *store in tempArray) {
                    NSString *permittype = [store objectForKey:@"permit_type"];
                    NSString *name = [store objectForKey:@"name"];
                    NSDictionary *coordDict = [store objectForKey:@"full_address_value"];
                    NSArray *coords = [coordDict objectForKey:@"coordinates"];
                    NSString *lat = coords[1];
                    NSString *lon = coords[0];
                    NSString *street = [store objectForKey:@"full_address_value_address"];
                    NSString *city = [store objectForKey:@"full_address_value_city"];
                    NSString *zip = [store objectForKey:@"full_address_value_zip"];
                    NSString *active = [store objectForKey:@"active"];
                    //NSLog(@"permit - %@, name -  %@, lat:%@, lon:%@, street address %@, city %@, zip %@, active %@", permittype, name, lat, lon, street, city, zip, active);
                    
                    BarsRestaurants *newstore = [[BarsRestaurants alloc] initWithName:name andpermitType:permittype andLat:lat andlon:lon andaddress:street andcity:city andzip:zip andactive:active];
                    [_barsArray addObject:newstore];
                }
                NSMutableArray *discardedItems = [NSMutableArray array];
                
                for (BarsRestaurants *loc in _barsArray) {
                    if (![loc.permitType containsString:@"FOOD"]) [discardedItems addObject:loc];
                    if (loc.Lat == 0) [discardedItems addObject:loc];
                }
                
                [_barsArray removeObjectsInArray:discardedItems];
                NSLog(@"total bars %li", _barsArray.count);
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"dataRcvMsg" object:nil];
                });
            }
        }
          ] resume];
    }
}

#pragma mark - Crime info pull
//https://data.detroitmi.gov/resource/i9ph-uyrp.json
- (IBAction)getCrime:(id)sender {
    [self getCrimeInfo];
}
- (void)getCrimeInfo {
    if (serverAvailable) {
        NSLog(@"Server Available");
        NSURL *fileURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://%@/resource/i9ph-uyrp.json?stateoffensefileclass=42000", _hostName]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:fileURL];
        [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
        [request setTimeoutInterval:30.0];
        NSURLSession *session = [NSURLSession sharedSession];
        NSLog(@"URL searhing: %@",fileURL);
        [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            NSLog(@"Got Response");
            if (([data length] > 0) && (error == nil)) {
                NSJSONSerialization *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                NSLog(@"Got jSON %@", json);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"dataRcvMsg" object:nil];
                });
            }
        }
          ] resume];
    }
}


#pragma mark - Interactivity Methods

- (IBAction)PolicePins:(id)sender {
    if (policePinsOff){
        policePinsOff=false;
        [self annotatePoliceStationLocations];
    }
}

- (IBAction)barsPins:(id)sender {
    if (barPinsoff) {
        barPinsoff=false;
        [self annotateBarLocations];
    }
}

- (IBAction)lStorePins:(id)sender {
    if (lStorePinsoff) {
        lStorePinsoff=false;
        [self annotateLStoreLocations];
    }
}

- (IBAction)removePins:(id)sender {
    barPinsoff = true;
    lStorePinsoff = true;
    policePinsOff = true;
    [self removeAllPins];

}

#pragma mark - Map Methods

- (void)zoomToPins {
    [_mapView showAnnotations:[_mapView annotations] animated:true];
}

- (void)removeAllPins {
    NSMutableArray *pinsToRemove = [[NSMutableArray alloc] init];
    for (id <MKAnnotation> annot in [_mapView annotations]) {
        if ([annot isKindOfClass:[MKPointAnnotation class]]) {
            [pinsToRemove addObject:annot];
        }
    }
    [_mapView removeAnnotations:pinsToRemove];
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    if ([overlay isKindOfClass:[MKCircle class]]) {
        MKCircleRenderer *renderer = [[MKCircleRenderer alloc]initWithOverlay:overlay];
        [renderer setFillColor:[UIColor blueColor]];
        [renderer setAlpha:0.2];
        return renderer;
    } else if ([overlay isKindOfClass:[MKPolygon class]]) {
        MKPolygonRenderer *pRenderer = [[MKPolygonRenderer alloc] initWithOverlay:overlay];
        [pRenderer setFillColor: [UIColor orangeColor]];
        [pRenderer setAlpha: 0.1];
    }
    return nil;
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if (annotation != mapView.userLocation) {
        MKPinAnnotationView *pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"Pin"];
        if (pinView == nil) {
            pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Pin"];
        }
        pinView.canShowCallout = true;
        pinView.animatesDrop = false;
        MyPointAnnotation *annot = (MyPointAnnotation *)annotation;
        if ([annot.pinType isEqualToString:@"lStore"]) {
            pinView.pinTintColor = [UIColor grayColor];
            pinView.alpha = 0.2;
        } else if ([annot.pinType isEqualToString:@"police"]){
            pinView.pinTintColor = [UIColor blueColor];
        } else if ([annot.pinType isEqualToString:@"bar"]){
            pinView.pinTintColor = [UIColor orangeColor];
            pinView.alpha = .5;
        }
        return pinView;
    }
    return nil;
}

#pragma mark - Police map Methods

- (void)annotatePoliceStationLocations {
    for (PoliceStations *loc in _policeArray) {
        MyPointAnnotation *pa1 = [[MyPointAnnotation alloc] init];
        pa1.coordinate = CLLocationCoordinate2DMake([loc.pLat floatValue], [loc.pLon floatValue]);
        //NSLog(@"Lat: %f and Lon: %f", [loc.pLat floatValue], [loc.pLon floatValue]);
        pa1.title = loc.pPrecinct;
        pa1.subtitle = loc.pCaptainName;
        pa1.pinType = @"police";
        [_mapView addAnnotation:pa1];
        
        MKCircle *cirlce = [MKCircle circleWithCenterCoordinate:pa1.coordinate radius:500];
        [_mapView addOverlay:cirlce level:MKOverlayLevelAboveRoads];
    }
    
    [self zoomToPins];
}

#pragma mark - Lstore map methods

- (void)annotateLStoreLocations {
    for (LiquorStore*loc in _lStoreArray) {
        MyPointAnnotation *pa1 = [[MyPointAnnotation alloc] init];
        pa1.coordinate = CLLocationCoordinate2DMake([loc.Lat floatValue], [loc.Lon floatValue]);
        //NSLog(@"Lat: %f and Lon: %f", [loc.Lat floatValue], [loc.Lon floatValue]);
        pa1.title = loc.name;
        pa1.pinType = @"lStore";
        [_mapView addAnnotation:pa1];
    }
    
    [self zoomToPins];
}

#pragma mark - Bars map methods

- (void)annotateBarLocations {
    for (BarsRestaurants*loc in _barsArray) {
        MyPointAnnotation *pa1 = [[MyPointAnnotation alloc] init];
        pa1.coordinate = CLLocationCoordinate2DMake([loc.Lat floatValue], [loc.Lon floatValue]);
        //NSLog(@"Lat: %f and Lon: %f", [loc.Lat floatValue], [loc.Lon floatValue]);
        pa1.title = loc.name;
        pa1.pinType = @"bar";
        [_mapView addAnnotation:pa1];
    }
    
    [self zoomToPins];
}

#pragma mark - Network Methods

-(void)updateReachabilityStatus:(Reachability *) currentReach {
    NSParameterAssert([currentReach isKindOfClass:[Reachability class]]);
    NetworkStatus netStatus = [currentReach currentReachabilityStatus];
    if (currentReach == hostReach) {
        switch (netStatus) {
            case NotReachable:
                NSLog(@"Sever Not Available");
                serverAvailable = false;
                break;
            case ReachableViaWWAN:
                NSLog(@"Server Reachable via WWAN");
                serverAvailable = true;
            case ReachableViaWiFi:
                NSLog(@"Server Reachable via WiFi");
                serverAvailable = true;
            default:
                break;
        }
    }
    if (currentReach == internetReach || currentReach == wifiReach) {
        switch (netStatus) {
            case NotReachable:
                NSLog(@"Internet not Available");
                internetAvailable = false;
                break;
            case ReachableViaWWAN:
                NSLog(@"Internet Available via WWAN");
                internetAvailable = true;
            case ReachableViaWiFi:
                NSLog(@"Internet Available via WiFi");
                internetAvailable = true;
            default:
                break;
        }
    }
}

-(void)reachablityChanged:(NSNotification *)notification {
    Reachability *currentReach = [notification object];
    [self updateReachabilityStatus:currentReach];
    if (_policeArray.count == 0 || _policeArray == nil) {
        [self getPoliceInfo];
    }
    if (_lStoreArray.count == 0 || _lStoreArray == nil) {
        [self getLiquorStoreInfo];
    }
    if (_barsArray.count == 0 || _barsArray == nil) {
        [self getBarRestaurantsInfo];
    }
}

-(void)searchResultRecv:(NSNotification *)notification {
    //NSLog(@"Reloading Table");
    //   [_ResultsCollectionView reloadData];
}

# pragma mark - Life Cycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    _hostName = @"data.detroitmi.gov";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachablityChanged:) name:kReachabilityChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchResultRecv:) name:@"dataRcvMsg" object:nil];
    hostReach = [Reachability reachabilityWithHostname:_hostName];
    [hostReach startNotifier];
    
    internetReach = [Reachability reachabilityForInternetConnection];
    [internetReach startNotifier];
    
    wifiReach = [Reachability reachabilityForLocalWiFi];
    [wifiReach startNotifier];
    
    _policeArray = [[NSMutableArray alloc] init];
    _lStoreArray = [[NSMutableArray alloc] init];
    _barsArray = [[NSMutableArray alloc] init];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end