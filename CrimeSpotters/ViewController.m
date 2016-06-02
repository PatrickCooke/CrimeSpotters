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
#import "CustomCollectionViewCell.h"
#import <MapKit/MapKit.h>

@interface ViewController ()

@property (nonatomic, strong)         NSString           *hostName;
@property (nonatomic, strong)         NSMutableArray     *policeArray;
@property (nonatomic, strong)         NSMutableArray     *unusedArray;
@property (nonatomic, strong)         NSMutableArray     *fireArray;
@property (nonatomic, weak)  IBOutlet MKMapView          *mapView;
@property (nonatomic, strong)         NSMutableArray     *lStoreArray;
@property (nonatomic, strong)         NSMutableArray     *barsArray;
@property (nonatomic, strong)         NSMutableArray     *sClubArray;
@property (nonatomic, strong)         NSMutableArray     *crimeArray;
@property (nonatomic, weak) IBOutlet  NSLayoutConstraint *insideMenuConstant;
@property (nonatomic, weak) IBOutlet  UICollectionView   *menuCollectionView;
@property (nonatomic, strong)         NSArray           *publicServicesArray;
@property (nonatomic, strong)         NSArray           *liquorTypeArray;
@property (nonatomic, strong)         NSArray           *crimeActsArray;
@property (nonatomic, strong)         NSArray           *publicServicesIconsArray;
@property (nonatomic, strong)         NSArray           *liquorTypeIconsArray;
@property (nonatomic, strong)         NSArray           *crimeActsIconsArray;
@property (nonatomic, weak) IBOutlet  UISlider          *policeAreaSlider;

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
bool stripClubPinsOff = true;
bool crimePinsoff = true;
bool menuvisable = true;
bool aggassaultPinsOff = true;
bool assaultPinsOff = true;
bool murderPinsoOff = true;
bool drunkPinsOff = true;
bool arsonPinsOff = true;
double policeArea = 3000.0;



#pragma mark - Collection View Methods

- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 3;
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section == 0){
        return _publicServicesArray.count;
    } else if (section == 1) {
        return _liquorTypeArray.count;
    } else if (section == 2) {
        return _crimeActsArray.count;
    } else {
        return 0;
    }
}

- (UICollectionViewCell*) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString* itemLabel = @"?";
    NSString* iconName = @"?";
    if (indexPath.section == 0){
        itemLabel = _publicServicesArray[indexPath.row];
        iconName = _publicServicesIconsArray[indexPath.row];
    } else if (indexPath.section == 1) {
        itemLabel = _liquorTypeArray[indexPath.row];
        iconName = _liquorTypeIconsArray[indexPath.row];
    } else if (indexPath.section == 2) {
        itemLabel = _crimeActsArray[indexPath.row];
        iconName = _crimeActsIconsArray[indexPath.row];
    }
    CustomCollectionViewCell* cell = (CustomCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.itemLabel.text = itemLabel;
    cell.itemImageView.image = [UIImage imageNamed: iconName];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0){
        switch (indexPath.row) {
            case 0:
                NSLog(@"Police");
                [self showPolice];
                break;
            case 1:
                NSLog(@"Fire");
                [ self showFire];
                break;
            default:
                break;
        }
    } else if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0:
                NSLog(@"Liquor Store");
                [self showLStore];
                break;
            case 1:
                NSLog(@"Bars/Restaurants");
                [self showBars];
                break;
            case 2:
                NSLog(@"Strip Clubs");
                [self showSClub];
                break;
            default:
                break;
        }
    } else if (indexPath.section == 2) {
        switch (indexPath.row) {
            case 0:
                NSLog(@"Arson");
                [self ShowArson];
                break;
            case 1:
                NSLog(@"Assault");
                [self ShowAssault];
                break;
            case 2:
                NSLog(@"AggAssault");
                [self ShowAggAssault];
                break;
            case 3:
                NSLog(@"Disorderly Conduct");
                [self ShowDisorderlyConduct];
                break;
            case 4:
                NSLog(@"Murder");
                [self ShowMurder];
                break;
            default:
                break;
        }
    }
}




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

- (void)getLLInfo {
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
                [_sClubArray removeAllObjects];
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
                    if (lat == NULL) {
                        NSLog(@"toss these out");
                    } else if ([permittype containsString:@"TLESSACT"]) {
                        [_sClubArray addObject:newstore];
                    } else if ([permittype containsString:@"ADDBAR"] || [permittype containsString:@"FOOD"] || [name containsString:@"PUB"] || /*[permittype containsString:@"OD-SERV"] &&*/ [name containsString:@"RESTAURANT"] || [name containsString:@"LOUNGE"]) {                        [_barsArray addObject:newstore];
                    } else {
                        LiquorStore *newstore = [[LiquorStore alloc] initWithName:name andpermitType:permittype andLat:lat andlon:lon andaddress:street andcity:city andzip:zip andactive:active];
                        [_lStoreArray addObject:newstore];
                    }
                }
                NSLog(@"Strip Clubs %li, Liquor %li, Bars %li", _sClubArray.count,_lStoreArray.count, _barsArray.count);
                
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
        NSURL *fileURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://%@/resource/i9ph-uyrp.json?$limit=20000&$$app_token=SiWSm0v7gKl8NxUd7vZCJQkzP", _hostName]];
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


#pragma mark - Interactivity Button Methods

-(IBAction)showHideMenu:(id)sender {
    if (menuvisable) {
        [UIView animateWithDuration:1.0 animations:^{
            [_menuCollectionView setAlpha:0.0];
            [self.view layoutIfNeeded];
        }];
        menuvisable = false;
    } else if (!menuvisable) {
        [UIView animateWithDuration:1.0 animations:^{
            [_menuCollectionView setAlpha:0.8];
            [self.view layoutIfNeeded];
        }];
        menuvisable = true;
    }
}

- (IBAction)removePins:(id)sender {
    barPinsoff = true;
    lStorePinsoff = true;
    stripClubPinsOff = true;
    policePinsOff = true;
    firePinsOff = true;
    murderPinsoOff = true;
    drunkPinsOff = true;
    aggassaultPinsOff = true;
    assaultPinsOff = true;
    arsonPinsOff = true;
    [self removeAllPins];
    [self removecircles];
    
}

#pragma mark - Show/Hide Pin Commands

- (void) showPolice {
    if (policePinsOff){
        policePinsOff=false;
        [self annotatePoliceStationLocations];
        
    } else {
        [self removePinTypes:@"police"];
        policePinsOff = true;
        
    }
}

- (void)showFire {
    if (firePinsOff){
        firePinsOff=false;
        [self annotateFireStationLocations];
    } else {
        [self removePinTypes:@"fire"];
        firePinsOff = true;
    }
}

- (void)showBars {
    if (barPinsoff) {
        barPinsoff=false;
        //[self annotateBarLocations];
        [self annotateLiquorLocations:_barsArray withCategory:@"bar"];
    } else {
        [self removePinTypes:@"bar"];
        barPinsoff = true;
    }
}

- (void)showLStore {
    if (lStorePinsoff) {
        lStorePinsoff=false;
        //[self annotateLStoreLocations];
        [self annotateLiquorLocations:_lStoreArray withCategory:@"lStore"];
    } else {
        [self removePinTypes:@"lStore"];
        lStorePinsoff=true;
    }
}

- (void)showSClub {
    if (stripClubPinsOff) {
        stripClubPinsOff=false;
        //[self annotateStripClubLocations];
        [self annotateLiquorLocations:_sClubArray withCategory:@"stripclub"];
    } else {
        [self removePinTypes:@"stripclub"];
        stripClubPinsOff=true;
    }
}

- (void)ShowMurder {
    if (murderPinsoOff) {
        murderPinsoOff=false;
        [self annotateMurderLocations];
    } else {
        [self removePinTypes:@"murder"];
        murderPinsoOff=true;
    }
}
- (void)ShowDisorderlyConduct {
    if (drunkPinsOff) {
        drunkPinsOff=false;
        [self annotateDisorderlyConductLocations];
    }else {
        [self removePinTypes:@"disorderlyconduct"];
        drunkPinsOff=true;
    }
}
- (void)ShowAssault {
    if (assaultPinsOff) {
        assaultPinsOff=false;
        [self annotateAssaultLocations];
    } else {
        [self removePinTypes:@"assault"];
        assaultPinsOff=true;
    }
}

- (void)ShowAggAssault {
    if (aggassaultPinsOff) {
        aggassaultPinsOff=false;
        [self annotateAGGAssaultLocations];
    } else {
        [self removePinTypes:@"aggassault"];
        aggassaultPinsOff=true;
    }
}

- (void)ShowArson {
    if (arsonPinsOff) {
        arsonPinsOff=false;
        [self annotateArsonLocations];
    } else {
        [self removePinTypes:@"arson"];
        arsonPinsOff=true;
    }
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

- (void)removePinTypes:(NSString *)pinType {
    NSMutableArray *pinsToRemove = [[NSMutableArray alloc] init];
    for (id <MKAnnotation> annot in [_mapView annotations]) {
        if ([annot isKindOfClass:[MyPointAnnotation class]]) {
            MyPointAnnotation *myPA = (MyPointAnnotation *)annot;
            if ([myPA.pinType isEqualToString:pinType]) {
                [pinsToRemove addObject:annot];
            }
        }
    }
    [_mapView removeAnnotations:pinsToRemove];
    NSMutableArray *circles = [[NSMutableArray alloc] init];
    for (id<MKOverlay> annot in _mapView.overlays){
        if ([annot isKindOfClass:[MKCircle class]]) {
            MyCircle *overlay = (MyCircle *)annot;
            if ([overlay.circleType isEqualToString:pinType]) {
                [circles addObject:annot];
            }
        }
    }
    [self.mapView removeOverlays:circles];
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    if ([overlay isKindOfClass:[MKCircle class]]) {
        MyCircle *currentCircle = (MyCircle *)overlay;
        MKCircleRenderer *renderer = [[MKCircleRenderer alloc]initWithOverlay:overlay];
        
        if ([currentCircle.circleType isEqualToString:@"police"]) {
            [renderer setFillColor:[UIColor blueColor]];
            [renderer setAlpha:0.1];
        } else if ([currentCircle.circleType isEqualToString: @"arson"]) {
            [renderer setFillColor:[UIColor colorWithRed:(160/255.0) green:(97/255.0) blue:(5/255.0) alpha:1]];
            [renderer setAlpha:0.8];
        } else if ([currentCircle.circleType isEqualToString:@"aggassault"]) {
            [renderer setFillColor:[UIColor darkGrayColor]];
            [renderer setAlpha:0.8];
        }else if ([currentCircle.circleType isEqualToString:@"assault"]) {
            [renderer setFillColor:[UIColor grayColor]];
            [renderer setAlpha:0.8];
        }else if ([currentCircle.circleType isEqualToString:@"disorderlyconduct"]) {
            [renderer setFillColor:[UIColor brownColor]];
            [renderer setAlpha:0.8];
        }else if ([currentCircle.circleType isEqualToString:@"murder"]) {
            [renderer setFillColor:[UIColor blackColor]];
            [renderer setAlpha:0.8];
        }
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
            pinView.pinTintColor = [UIColor lightGrayColor];
            pinView.alpha = 0.4;
        } else if ([annot.pinType isEqualToString:@"police"]){
            pinView.pinTintColor = [UIColor blueColor];
            pinView.alpha = 1.0;
        } else if ([annot.pinType isEqualToString:@"bar"]){
            pinView.pinTintColor = [UIColor orangeColor];
            pinView.alpha = 0.5;
        } else if ([annot.pinType isEqualToString:@"stripclub"]){
            pinView.pinTintColor = [UIColor purpleColor];
            pinView.alpha = 0.5;
        }else if ([annot.pinType isEqualToString:@"assault"]){
            pinView.pinTintColor = [UIColor cyanColor];
            pinView.alpha = 0.5;
        }else if ([annot.pinType isEqualToString:@"murder"]){
            pinView.pinTintColor = [UIColor blackColor];
            pinView.alpha = 0.5;
        }else if ([annot.pinType isEqualToString:@"disorderlyconduct"]){
            pinView.pinTintColor = [UIColor brownColor];
            pinView.alpha = 0.5;
        }else if ([annot.pinType isEqualToString:@"fire"]){
            pinView.pinTintColor = [UIColor redColor];
            pinView.alpha = 0.5;
        }else if ([annot.pinType isEqualToString:@"arson"]){
            pinView.pinTintColor = [UIColor yellowColor];
            pinView.alpha = 0.5;
        }else if ([annot.pinType isEqualToString:@"aggassault"]){
            pinView.pinTintColor = [UIColor greenColor];
            pinView.alpha = 0.5;
        }
        return pinView;
    }
    return nil;
}

#pragma mark - Public Services Methods

- (void)annotatePoliceStationLocations {
    for (PoliceStations *loc in _policeArray) {
        MyPointAnnotation *pa1 = [[MyPointAnnotation alloc] init];
        pa1.coordinate = CLLocationCoordinate2DMake([loc.pLat floatValue], [loc.pLon floatValue]);
        pa1.title = loc.pPrecinct;
        pa1.subtitle = loc.pCaptainName;
        pa1.pinType = @"police";
        [_mapView addAnnotation:pa1];
        
        MyCircle *cirlce = [MyCircle circleWithCenterCoordinate:pa1.coordinate radius:policeArea];
        cirlce.circleType=@"police";
        [_mapView addOverlay:cirlce level:MKOverlayLevelAboveRoads];
    }
    [self zoomToPins];
}

-(IBAction)sliderchanged:(UISlider *)slider {
    policeArea = (_policeAreaSlider.value * 6000);
    NSLog(@"Slider Changed: %f, %f", policeArea, _policeAreaSlider.value);

    for (id<MKOverlay> annot in _mapView.overlays){
        if ([annot isKindOfClass:[MKCircle class]]) {
            MyCircle *overlay = (MyCircle *)annot;
            if ([overlay.circleType isEqualToString:@"police"]) {
                //NSLog(@"is Police");
                MyCircle *newOverlay = [MyCircle circleWithCenterCoordinate:overlay.coordinate radius:overlay.radius];
                newOverlay.circleType = overlay.circleType;
                [_mapView removeOverlay:overlay];
                [_mapView addOverlay:newOverlay];
            }
        }
    }

}

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
#pragma mark - Annotate Liquor Licenses methods


- (void)annotateLiquorLocations:(NSMutableArray*)arrayName withCategory:(NSString*)category {
    for (BarsRestaurants*loc in arrayName) {
        MyPointAnnotation *pa1 = [[MyPointAnnotation alloc] init];
        pa1.coordinate = CLLocationCoordinate2DMake([loc.Lat floatValue], [loc.Lon floatValue]);
        pa1.title = loc.name;
        pa1.pinType = category;
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
            pa1.pinType = @"murder";
            MyCircle *cirlce = [MyCircle circleWithCenterCoordinate:pa1.coordinate radius:150];
            cirlce.circleType=@"murder";
            [_mapView addOverlay:cirlce level:MKOverlayLevelAboveRoads];
        }
    }
    [self zoomToPins];
}

- (void)annotateDisorderlyConductLocations {
    for (Crime *loc in _crimeArray) {
        if ([loc.crimeClass isEqualToString:@"42000"] || [loc.crimeClass isEqualToString:@"53001"]) {
            CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([loc.lat floatValue], [loc.lon floatValue]);
            MyPointAnnotation *pa1 = [[MyPointAnnotation alloc] init];
            pa1.coordinate = coord;
            pa1.title = loc.category;
            pa1.subtitle = loc.date;
            pa1.pinType = @"disorderlyconduct";
            MyCircle *cirlce = [MyCircle circleWithCenterCoordinate:pa1.coordinate radius:150];
            cirlce.circleType=@"disoderlyconduct";
            [_mapView addOverlay:cirlce level:MKOverlayLevelAboveRoads];
        }
    }
    [self zoomToPins];
}

- (void)annotateAssaultLocations {
    for (Crime *loc in _crimeArray) {
        if ([loc.crimeClass isEqualToString:@"13001"]) {
            CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([loc.lat floatValue], [loc.lon floatValue]);
            MyPointAnnotation *pa1 = [[MyPointAnnotation alloc] init];
            pa1.coordinate = coord;
            pa1.title = loc.category;
            pa1.subtitle = loc.date;
            pa1.pinType = @"assault";
            MyCircle *cirlce = [MyCircle circleWithCenterCoordinate:pa1.coordinate radius:150];
            cirlce.circleType=@"assault";
            [_mapView addOverlay:cirlce level:MKOverlayLevelAboveRoads];
        }
    }
    [self zoomToPins];
}

- (void)annotateAGGAssaultLocations {
    for (Crime *loc in _crimeArray) {
        if ([loc.crimeClass isEqualToString:@"13002"]) {
            CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([loc.lat floatValue], [loc.lon floatValue]);
            MyPointAnnotation *pa1 = [[MyPointAnnotation alloc] init];
            pa1.coordinate = coord;
            pa1.title = loc.category;
            pa1.subtitle = loc.date;
            pa1.pinType = @"aggassault";
            MyCircle *cirlce = [MyCircle circleWithCenterCoordinate:pa1.coordinate radius:150];
            cirlce.circleType=@"aggassault";
            [_mapView addOverlay:cirlce level:MKOverlayLevelAboveRoads];
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
            MyCircle *cirlce = [MyCircle circleWithCenterCoordinate:pa1.coordinate radius:150];
            cirlce.circleType=@"arson";
            [_mapView addOverlay:cirlce level:MKOverlayLevelAboveRoads];
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
    if (_crimeArray.count == 0 || _crimeArray == nil) {
        [self getCrimeInfo];
    }
    if (_fireArray.count == 0 || _fireArray == nil) {
        [self getFireInfo];
    }
    if (_lStoreArray.count == 0 || _lStoreArray == nil || _barsArray.count == 0 || _barsArray == nil || _sClubArray.count == 0 || _sClubArray == nil) {
        [self getLLInfo];
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
    _unusedArray = [[NSMutableArray alloc] init];
    _lStoreArray = [[NSMutableArray alloc] init];
    _barsArray = [[NSMutableArray alloc] init];
    _crimeArray = [[NSMutableArray alloc] init];
    _fireArray = [[NSMutableArray alloc] init];
    _sClubArray = [[NSMutableArray alloc] init];

    _publicServicesArray = @[@"Police", @"Fire"];
    _liquorTypeArray = @[@"Liquor Stores", @"Bars/Restaurants", @"Strip Clubs"];
    _crimeActsArray = @[@"Arson", @"Assault", @"Aggrevated Assault", @"Disorderly Conduct", @"Murder"];
    _publicServicesIconsArray = @[@"Police", @"Fire"];
    _liquorTypeIconsArray = @[@"LiquorStores", @"BarsRestaurants", @"StripClubs"];
    _crimeActsIconsArray = @[@"Arson", @"Assault", @"AggrevatedAssault", @"DisorderlyConduct", @"Murder"];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"out of memory");
}

@end
