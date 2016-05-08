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
#import "FireStations.h"
#import "LiquorStore.h"
#import "Crime.h"
#import "BarsRestaurants.h"
#import "MyPointAnnotation.h"
#import "MyCircle.h"
#import <MapKit/MapKit.h>

@interface ViewController ()

@property (nonatomic, strong)         NSString           *hostName;
@property (nonatomic, strong)         NSMutableArray     *policeArray;
@property (nonatomic, strong)         NSMutableArray     *fireArray;
@property (nonatomic, weak)  IBOutlet MKMapView          *mapView;
@property (nonatomic, strong)         NSMutableArray     *lStoreArray;
@property (nonatomic, strong)         NSMutableArray     *barsArray;
@property (nonatomic, strong)         NSMutableArray     *crimeArray;
@property (nonatomic, weak)  IBOutlet UIView             *menuView;
@property (nonatomic, weak) IBOutlet  NSLayoutConstraint *insideMenuConstant;

@end

@implementation ViewController

#pragma mark - Global Variables

Reachability *hostReach;
Reachability *internetReach;
Reachability *wifiReach;
bool internetAvailable;
bool serverAvailable;
bool policePinsOff = true;
bool firePinsOff = true;
bool barPinsoff = true;
bool lStorePinsoff = true;
bool crimePinsoff = true;
bool menuhidden = true;
bool assaultPinsOff = true;
bool murderPinsoOff = true;
bool drunkPinsOff = true;
bool arsonPinsOff = true;


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

#pragma mark - Pull Fire Station Data

- (void)getFireInfo {
    NSLog(@"GPI");
    if (serverAvailable) {
        NSLog(@"Server Available");
        NSURL *fileURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://%@/resource/hz79-58xh.json?$$app_token=bjp8KrRvAPtuf809u1UXnI0Z8", _hostName]];
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
                [_fireArray removeAllObjects];
                NSArray *tempArray = (NSArray *)json;
                for (NSDictionary *Station in tempArray) {
                    NSString *station = [Station objectForKey:@"station"];
                    NSString *Ladder = [Station objectForKey:@"ladder"];
                    NSDictionary *coordDict = [Station objectForKey:@"full_address"];
                    NSArray *coords = [coordDict objectForKey:@"coordinates"];
                    NSString *lat = coords[1];
                    NSString *lon = coords[0];
                    NSString *battalion = [Station objectForKey:@"battalion"];
                    NSString *engine = [Station objectForKey:@"engine"];
                    //NSLog(@" Station:%@, ladder:%@ lat:%@ lon:%@ battalion:%@, engine:%@",Station, Ladder, lat,lon, battalion, engine);
                    FireStations *newstation = [[FireStations alloc] initWithStation:station andladder:Ladder andlat:lat andLon:lon andBattalion:battalion andEngine:engine];
                    [_fireArray addObject:newstation];
                }
                NSLog(@"Fire Stations: %li", _fireArray.count);
                
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
//- (IBAction)getCrime:(id)sender {
//    [self getCrimeInfo];
//}
- (void)getCrimeInfo {
    if (serverAvailable) {
        NSLog(@"Server Available");
        NSURL *fileURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://%@/resource/i9ph-uyrp.json?$limit=10000&$$app_token=SiWSm0v7gKl8NxUd7vZCJQkzP", _hostName]];
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
                [_crimeArray removeAllObjects];
                NSArray *tempArray = (NSArray *)json;
                for (NSDictionary *crime in tempArray) {
                    NSString *category = [crime objectForKey:@"category"];
                    NSString *crimeCode = [crime objectForKey:@"stateoffensefileclass"];
                    NSDictionary *coordDict = [crime objectForKey:@"location"];
                    NSArray *coords = [coordDict objectForKey:@"coordinates"];
                    NSString *lat = coords[1];
                    NSString *lon = coords[0];
                    NSString *date1 = [crime objectForKey:@"incidentdate"];
                    NSString *date = [date1 stringByReplacingOccurrencesOfString:@"T00:00:00.000" withString:@""];
                    //NSLog(@"code -  %@, lat:%@, lon:%@ date %@", crimeCode, lat, lon, date);
                    Crime *newCrime = [[Crime alloc] initWithCategory:category andCrimeClass:crimeCode andLat:lat andLon:lon andDate:date];
                    [_crimeArray addObject:newCrime];
                }
                NSMutableArray *discardedItems = [NSMutableArray array];
                
                for (Crime *loc in _crimeArray) {
                    if (loc.lat == 0) [discardedItems addObject:loc];
                    if ([loc.lat floatValue] > 90) [discardedItems addObject:loc];
                }
                
                [_crimeArray removeObjectsInArray:discardedItems];
                NSLog(@"total crimes %li", _crimeArray.count);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"dataRcvMsg" object:nil];
                });
            }
        }
          ] resume];
    }
}


#pragma mark - Interactivity Methods

-(IBAction)showHideMenu:(id)sender {
    if (!_menuView.hidden) {
        menuhidden = false;
        [UIView animateWithDuration:1.0 animations:^{
            [_menuView setAlpha:0.0];
            [self.view layoutIfNeeded];
            [_menuView setHidden:true];
        }];
    } else {
        menuhidden = true;
        [UIView animateWithDuration:1.0 animations:^{
            [_menuView setAlpha:1.0];
            [_menuView setHidden:false];
            [self.view layoutIfNeeded];
        }];
    }
}

- (IBAction)PolicePins:(id)sender {
    if (policePinsOff){
        policePinsOff=false;
        [self annotatePoliceStationLocations];
    }
}

- (IBAction)FirePins:(id)sender {
    if (firePinsOff){
        firePinsOff=false;
        [self annotateFireStationLocations];
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

- (IBAction)ShowMurder:(id)sender {
    if (murderPinsoOff) {
        murderPinsoOff=false;
        [self annotateMurderLocations];
    }

}
- (IBAction)ShowDrunkenness:(id)sender {
    if (drunkPinsOff) {
        drunkPinsOff=false;
        [self annotateDrunkennessLocations];
    }
    
}
- (IBAction)ShowAssault:(id)sender {
    if (assaultPinsOff) {
        assaultPinsOff=false;
        [self annotateAssaultLocations];
    }
    
}

- (IBAction)ShowArson:(id)sender {
    if (arsonPinsOff) {
        arsonPinsOff=false;
        [self annotateArsonLocations];
    }
}

- (IBAction)removePins:(id)sender {
    barPinsoff = true;
    lStorePinsoff = true;
    policePinsOff = true;
    firePinsOff = true;
    murderPinsoOff = true;
    drunkPinsOff = true;
    assaultPinsOff = true;
    arsonPinsOff = true;
    [self removeAllPins];
    [self removecircles];

}

#pragma mark - Map Methods

- (void)zoomToPins {
    [_mapView showAnnotations:[_mapView annotations] animated:true];
}
-(void) removecircles {
    for (id<MKOverlay> overlay in _mapView.overlays)
    {
        [self.mapView removeOverlay:overlay];
    }
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
        MyCircle *circle = (MyCircle *)overlay;
        MKCircleRenderer *renderer = [[MKCircleRenderer alloc]initWithOverlay:overlay];
        
//        if ([circle.circleType isEqualToString:@"police"]) {
            [renderer setFillColor:[UIColor blueColor]];
            [renderer setAlpha:0.2];
//        } else if ([circle.circleType isEqualToString: @"crime"]) {
//            [renderer setFillColor:[UIColor darkGrayColor]];
//            [renderer setAlpha:0.6];
//        } else if ([circle.circleType isEqualToString:@""]) {
//            [renderer setFillColor:[UIColor lightGrayColor]];
//            [renderer setAlpha:0.1];
//        }

        return renderer;

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
            pinView.pinTintColor = [UIColor greenColor];
            pinView.alpha = 0.5;
        } else if ([annot.pinType isEqualToString:@"police"]){
            pinView.pinTintColor = [UIColor blueColor];
            pinView.alpha = 1.0;
        } else if ([annot.pinType isEqualToString:@"bar"]){
            pinView.pinTintColor = [UIColor orangeColor];
            pinView.alpha = 0.5;
        } else if ([annot.pinType isEqualToString:@"crime"]){
            pinView.pinTintColor = [UIColor darkGrayColor];
            pinView.alpha = 0.5;
        }else if ([annot.pinType isEqualToString:@"fire"]){
            pinView.pinTintColor = [UIColor redColor];
            pinView.alpha = 0.5;
        }else if ([annot.pinType isEqualToString:@"arson"]){
            pinView.pinTintColor = [UIColor blackColor];
            pinView.alpha = 0.5;
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
        
        
        MyCircle *cirlce = [MyCircle circleWithCenterCoordinate:pa1.coordinate radius:3000];
        [_mapView addOverlay:cirlce level:MKOverlayLevelAboveRoads];
        cirlce.circleType=@"police";
    }
    
    [self zoomToPins];
}

#pragma mark - Fire Station methods
- (void)annotateFireStationLocations {
    for (FireStations *loc in _fireArray) {
        MyPointAnnotation *pa1 = [[MyPointAnnotation alloc] init];
        pa1.coordinate = CLLocationCoordinate2DMake([loc.lat floatValue], [loc.lon floatValue]);
        //NSLog(@"Lat: %f and Lon: %f", [loc.pLat floatValue], [loc.pLon floatValue]);
        pa1.title = loc.station;
        pa1.subtitle = loc.battalion;
        pa1.pinType = @"fire";
        [_mapView addAnnotation:pa1];
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

#pragma mark - Crime Methods
- (void)annotateMurderLocations {
    for (Crime *loc in _crimeArray) {
        if ([loc.crimeClass isEqualToString:@"09001"] || [loc.crimeClass isEqualToString:@"09002"] || [loc.crimeClass isEqualToString:@"09003"] ||[loc.crimeClass isEqualToString:@"09004"]) {
            CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([loc.lat floatValue], [loc.lon floatValue]);
            MyPointAnnotation *pa1 = [[MyPointAnnotation alloc] init];
            pa1.coordinate = coord;
            pa1.title = loc.category;
            pa1.subtitle = loc.date;
            pa1.pinType = @"crime";
            [_mapView addAnnotation:pa1];
        }
    }
    [self zoomToPins];
}
- (void)annotateDrunkennessLocations {
    for (Crime *loc in _crimeArray) {
        if ([loc.crimeClass isEqualToString:@"42000"] || [loc.crimeClass isEqualToString:@"53001"]) {
            CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([loc.lat floatValue], [loc.lon floatValue]);
            MyPointAnnotation *pa1 = [[MyPointAnnotation alloc] init];
            pa1.coordinate = coord;
            pa1.title = loc.category;
            pa1.subtitle = loc.date;
            pa1.pinType = @"crime";
            [_mapView addAnnotation:pa1];
        }
    }
    [self zoomToPins];
}

- (void)annotateAssaultLocations {
    for (Crime *loc in _crimeArray) {
        if ([loc.crimeClass isEqualToString:@"13001"] || [loc.crimeClass isEqualToString:@"53001"]) {
            CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([loc.lat floatValue], [loc.lon floatValue]);
            MyPointAnnotation *pa1 = [[MyPointAnnotation alloc] init];
            pa1.coordinate = coord;
            pa1.title = loc.category;
            pa1.subtitle = loc.date;
            pa1.pinType = @"crime";
            [_mapView addAnnotation:pa1];
        }
    }
    [self zoomToPins];
}
- (void)annotateArsonLocations {
    for (Crime *loc in _crimeArray) {
        if ([loc.crimeClass isEqualToString:@"20000"]) {
            CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([loc.lat floatValue], [loc.lon floatValue]);
            MyPointAnnotation *pa1 = [[MyPointAnnotation alloc] init];
            pa1.coordinate = coord;
            pa1.title = loc.category;
            pa1.subtitle = loc.date;
            pa1.pinType = @"arson";
            [_mapView addAnnotation:pa1];
        }
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
    if (_crimeArray.count == 0 || _crimeArray == nil) {
        [self getCrimeInfo];
    }
    if (_fireArray.count == 0 || _fireArray == nil) {
        [self getFireInfo];
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
    _crimeArray = [[NSMutableArray alloc] init];
    _fireArray = [[NSMutableArray alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
