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
#import "Property.h"
#import "BarsRestaurants.h"
#import "MyPointAnnotation.h"
#import "MyCircle.h"
#import "CustomCollectionViewCell.h"
#import "MenuHeaderCollectionReusableView.h"
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
@property (nonatomic, strong)         NSMutableArray     *propertyArray;
//@property (nonatomic, weak) IBOutlet  NSLayoutConstraint *insideMenuConstant;
@property (nonatomic, weak) IBOutlet  UICollectionView   *menuCollectionView;
@property (nonatomic, strong)         NSArray           *publicServicesArray;
@property (nonatomic, strong)         NSArray           *liquorTypeArray;
@property (nonatomic, strong)         NSArray           *crimeActsArray;
@property (nonatomic, strong)         NSArray           *publicServicesIconsArray;
@property (nonatomic, strong)         NSArray           *liquorTypeIconsArray;
@property (nonatomic, strong)         NSArray           *crimeActsIconsArray;
@property (nonatomic, strong)         NSArray           *propertyIconsArray;
@property (nonatomic, strong)         NSArray           *propertiesSoldArray;
@property (nonatomic, weak) IBOutlet  UISlider          *policeAreaSlider;
@property (nonatomic, weak) IBOutlet  UILabel           *policeRadiusLabel;
@property (nonatomic, weak) IBOutlet  UILabel           *collectionViewHeaderLabel;
@property (nonatomic, weak) IBOutlet  UILabel           *lowMoneyLabel;
@property (nonatomic, weak) IBOutlet  UILabel           *highMoneyLabel;
@property (nonatomic, weak) IBOutlet  UIImageView       *propertyPriceImageView;



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
bool property0PinsOff = true;
bool property1PinsOff = true;
bool property2PinsOff = true;
bool property3PinsOff = true;
bool property4PinsOff = true;



#pragma mark - Collection View Methods

- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 4;
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section == 0){
        return _publicServicesArray.count;
    } else if (section == 1) {
        return _liquorTypeArray.count;
    } else if (section == 2) {
        return _crimeActsArray.count;
    } else if (section == 3) {
        return _propertiesSoldArray.count;
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
    } else if (indexPath.section == 3) {
        itemLabel = _propertiesSoldArray[indexPath.row];
        iconName = _propertyIconsArray[indexPath.row];
    }
    
    CustomCollectionViewCell* cell = (CustomCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.itemLabel.text = itemLabel;
    cell.itemImageView.image = [UIImage imageNamed: iconName];
    return cell;
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if (kind == UICollectionElementKindSectionHeader) {
        MenuHeaderCollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header" forIndexPath:indexPath];
        if (indexPath.section == 0) {
            headerView.sectionLabel.text = [NSString stringWithFormat: @"Public Services"];
        } else if (indexPath.section == 1) {
            headerView.sectionLabel.text = [NSString stringWithFormat: @"Liquor License Type"];
        } else if (indexPath.section == 2) {
            headerView.sectionLabel.text = [NSString stringWithFormat: @"Crime Type"];
        } else if (indexPath.section == 3) {
            headerView.sectionLabel.text = [NSString stringWithFormat:@"Properties sold"];
        }
        return headerView;
    }
    return nil;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CustomCollectionViewCell *cell = (CustomCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [cell.activityIndicator startAnimating];
    
    if (indexPath.section == 0){
        switch (indexPath.row) {
            case 0:
                NSLog(@"Police");
                [self checkPolice];
                break;
            case 1:
                NSLog(@"Fire");
                [self checkFire];
                break;
            default:
                break;
        }
    } else if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0:
                NSLog(@"Liquor Store");
                [self checkLStore];
                break;
            case 1:
                NSLog(@"Bars/Restaurants");
                [self checkBars];
                break;
            case 2:
                NSLog(@"Strip Clubs");
                [self checkSClubs];
                break;
            default:
                break;
        }
    } else if (indexPath.section == 2) {
        switch (indexPath.row) {
            case 0:
                NSLog(@"Arson");
                [self checkArson];
                break;
            case 1:
                NSLog(@"Assault");
                [self checkAssault];
                break;
            case 2:
                NSLog(@"AggAssault");
                [self checkaggAssault];
                break;
            case 3:
                NSLog(@"Disorderly Conduct");
                [self checkDisorderly];
                break;
            case 4:
                NSLog(@"Murder");
                [self checkMurder];
                break;
            default:
                break;
        }
    } else if (indexPath.section == 3) {
        switch (indexPath.row) {
            case 0:
                NSLog(@"prop0");
                [self checkProperty0];
                break;
            case 1:
                NSLog(@"prop1");
                [self checkProperty1];
                break;
            case 2:
                NSLog(@"prop2");
                [self checkProperty2];
                break;
            case 3:
                NSLog(@"prop3");
                [self checkProperty3];
                break;
            case 4:
                NSLog(@"prop4");
                [self checkProperty4];
                break;
            default:
                break;
        }
    }
}

#pragma mark - Pull Police Data

- (void)getPoliceInfo {
    //    NSLog(@"GPI");
    if (serverAvailable) {
        //NSLog(@"Server Available");
        NSURL *fileURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://%@/resource/3n6r-g9kp.json?$$app_token=bjp8KrRvAPtuf809u1UXnI0Z8", _hostName]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:fileURL];
        [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
        [request setTimeoutInterval:30.0];
        NSURLSession *session = [NSURLSession sharedSession];
        // NSLog(@"URL searhing: %@",fileURL);
        [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            NSLog(@"Got Police Response");
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
                //NSLog(@"Police records %@", _policeArray.count);
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"policeDataRcvMsg" object:nil];
                });
            }}] resume];
    }
}

#pragma mark - Pull property Data
/*
 website source for property class code  - https://www.michigan.gov/documents/treasury/STC_Recommended_Codes_351268_7.pdf
 api data displayed- https://data.detroitmi.gov/Property-Parcels/Property-Sales-History/w8m7-eib7
 api source data - https://dev.socrata.com/foundry/data.detroitmi.gov/fg2b-gvgp
 */
- (void)getPropertyInfo:(NSString *) proptype {
    //    NSLog(@"GPI");
    if (serverAvailable) {
        //NSLog(@"Server Available");
        NSURL *fileURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://goo.gl/YBS2Sn"]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:fileURL];
        [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
        [request setTimeoutInterval:30.0];
        NSURLSession *session = [NSURLSession sharedSession];
        // NSLog(@"URL searhing: %@",fileURL);
        [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            NSLog(@"Got Property Response");
            if (([data length] > 0) && (error == nil)) {
                NSJSONSerialization *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                //NSLog(@"Got jSON %@", json);
                [_propertyArray removeAllObjects];
                NSArray *tempArray = (NSArray *)json;
                for (NSDictionary *property in tempArray) {
                    
                    NSString *Address = [property objectForKey:@"propaddr"];
                    NSString *zip = [property objectForKey:@"propzip"];
                    NSString *price = [property objectForKey:@"saleprice"];
                    NSString *propclass = [property objectForKey:@"propclass"];
                    NSString *parcelno = [property objectForKey:@"propno"];
                    NSString *propLat = [property objectForKey:@"latitude"];
                    NSString *propLon = [property objectForKey:@"longitude"];
                    if (price.integerValue >= 1) {
                        if ([propclass isEqualToString:@"401"] || [propclass isEqualToString:@"402"] || [propclass isEqualToString:@"403"] || [propclass isEqualToString:@"404"] || [propclass isEqualToString:@"407"] || [propclass isEqualToString:@"410"] || [propclass isEqualToString:@"411"] || [propclass isEqualToString:@"420"] || [propclass isEqualToString:@"451"] || [propclass isEqualToString:@"207"]){
                            Property *newProperty = [[Property alloc] initWithpropPrice:price andpropClass:propclass andpropAddress:Address andpropZip:zip andparcelNumber:parcelno andpropLat:propLat andpropLon:propLon];
                            
                            [_propertyArray addObject:newProperty];
                        }
                    }
                }
                //NSLog(@"property records %li", _propertyArray.count);
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSString *notificationname = [NSString stringWithFormat:@"%@DataRcvMsg",proptype];
                    [[NSNotificationCenter defaultCenter] postNotificationName: notificationname object:nil];
                });
            }}] resume];
    }
}


#pragma mark - Pull Fire Station Data

- (void)getFireInfo {
    //    NSLog(@"GPI");
    if (serverAvailable) {
        //NSLog(@"Server Available");
        NSURL *fileURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://%@/resource/hz79-58xh.json?$$app_token=bjp8KrRvAPtuf809u1UXnI0Z8", _hostName]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:fileURL];
        [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
        [request setTimeoutInterval:30.0];
        NSURLSession *session = [NSURLSession sharedSession];
        //NSLog(@"URL searhing: %@",fileURL);
        [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            NSLog(@"Got Fire Response");
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
               // NSLog(@"Fire Stations: %li", _fireArray.count);
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"fireDataRcvMsg" object:nil];
                });
            }}] resume];
    }
}


#pragma mark - Liquor Store Data

- (void)getLLInfo:(NSString *)type {
    if (serverAvailable) {
        //NSLog(@"Server Available");
        NSURL *fileURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://%@/resource/djd8-sm8q.json", _hostName]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:fileURL];
        [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
        [request setTimeoutInterval:30.0];
        NSURLSession *session = [NSURLSession sharedSession];
        //        NSLog(@"URL searching: %@",fileURL);
        [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            NSLog(@"Got LL Response");
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
                    } else if ([permittype containsString:@"TLESSACT"]) {
                        [_sClubArray addObject:newstore];
                    } else if ([permittype containsString:@"ADDBAR"] || [permittype containsString:@"FOOD"] || [name containsString:@"PUB"] || [permittype containsString:@"OD-SERV"] || [name containsString:@"RESTAURANT"] || [name containsString:@"LOUNGE"]) {                        [_barsArray addObject:newstore];
                    } else {
                        LiquorStore *newstore = [[LiquorStore alloc] initWithName:name andpermitType:permittype andLat:lat andlon:lon andaddress:street andcity:city andzip:zip andactive:active];
                        [_lStoreArray addObject:newstore];
                    }
                }
                //NSLog(@"Strip Clubs %li, Liquor %li, Bars %li", _sClubArray.count,_lStoreArray.count, _barsArray.count);
                NSString *message = [NSString stringWithFormat:@"%@DataRcvMsg",type];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:message object:nil];
                });
            }
        }
          ] resume];
    }
}

#pragma mark - Crime info pull
//https://data.detroitmi.gov/resource/i9ph-uyrp.json

- (void)getCrimeInfo:(NSString *)type {
    if (serverAvailable) {
        //NSLog(@"Server Available");
        NSURL *fileURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://%@/resource/i9ph-uyrp.json?$limit=10000&$$app_token=SiWSm0v7gKl8NxUd7vZCJQkzP", _hostName]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:fileURL];
        [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
        [request setTimeoutInterval:30.0];
        NSURLSession *session = [NSURLSession sharedSession];
        //NSLog(@"URL searching: %@",fileURL);
        [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            NSLog(@"Got Crime Response");
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
                    if (loc.lat == NULL) [discardedItems addObject:loc];
                    if ([loc.lat floatValue] > 90) [discardedItems addObject:loc];
                }
                
                [_crimeArray removeObjectsInArray:discardedItems];
                //NSLog(@"total crimes %li", _crimeArray.count);
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSString *message = [NSString stringWithFormat:@"%@DataRcvMsg",type];
                    [[NSNotificationCenter defaultCenter] postNotificationName:message object:nil];
                });
            }
        }
          ] resume];
    }
}


#pragma mark - Interactivity Button Methods


-(IBAction)showHideMenu:(id)sender {
    if (menuvisable) {
        [UIView animateWithDuration:0.5 animations:^{
            [_menuCollectionView setAlpha:0.0];
            [self.view layoutIfNeeded];
        }];
        menuvisable = false;
    } else if (!menuvisable) {
        [UIView animateWithDuration:0.5 animations:^{
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
    property0PinsOff = true;
    property1PinsOff = true;
    property2PinsOff = true;
    property3PinsOff = true;
    property4PinsOff = true;
    [self removeAllPins];
    [self removecircles];
    [_policeAreaSlider setAlpha:0.0];
    [_policeRadiusLabel setAlpha:0.0];
    
    
    
}

#pragma mark - Show/Hide Pin Commands

-(void) checkPolice {
    if (_policeArray.count == 0 || _policeArray == nil) {
        NSLog(@"no data, pulling police data");
        [self getPoliceInfo];
    } else {
        NSLog(@"have police data, showing police");
        [self showPolice];
    }
}


- (void) showPolice {
    if (policePinsOff){
        policePinsOff=false;
        [self annotatePoliceStationLocations];
        [UIView animateWithDuration:0.5 animations:^{
            [_policeAreaSlider setAlpha:1.0];
            [_policeRadiusLabel setAlpha:0.8];
            [self.view layoutIfNeeded];
        }];
    } else {
        [self removePinTypes:@"police"];
        policePinsOff = true;
        [UIView animateWithDuration:0.5 animations:^{
            [_policeAreaSlider setAlpha:0.0];
            [_policeRadiusLabel setAlpha:0.0];
            [self.view layoutIfNeeded];
        }];
        [self cancelAnnimationForRow:0 inSection:0];
    }
}

-(void) checkFire {
    if (_fireArray.count == 0 || _fireArray == nil) {
        NSLog(@"no data, pulling fire data");
        [self getFireInfo];
    } else {
        NSLog(@"have fire data, showing fire");
        [self showFire];
    }
}

- (void)showFire {
    if (firePinsOff){
        firePinsOff=false;
        [self annotateFireStationLocations];
    } else {
        [self removePinTypes:@"fire"];
        firePinsOff = true;
        [self cancelAnnimationForRow:1 inSection:0];
    }
}

-(void) checkBars {
    if (_lStoreArray.count == 0 || _lStoreArray == nil || _barsArray.count == 0 || _barsArray == nil || _sClubArray.count == 0 || _sClubArray == nil) {
        NSLog(@"no data, pulling LL data");
        [self getLLInfo:@"bar"];
    } else {
        NSLog(@"have bLL data, showing bars");
        [self showBars];
    }
}

- (void)showBars {
    if (barPinsoff) {
        barPinsoff=false;
        [self annotateLiquorLocations:_barsArray withCategory:@"bar"];
    } else {
        [self removePinTypes:@"bar"];
        barPinsoff = true;
        [self cancelAnnimationForRow:1 inSection:1];
    }
}

-(void) checkLStore {
    if (_lStoreArray.count == 0 || _lStoreArray == nil || _barsArray.count == 0 || _barsArray == nil || _sClubArray.count == 0 || _sClubArray == nil) {
        NSLog(@"no data, pulling LL data");
        [self getLLInfo:@"lStore"];
    } else {
        NSLog(@"have bLL data, showing lStores");
        [self showLStore];
    }
}

- (void)showLStore {
    if (lStorePinsoff) {
        lStorePinsoff=false;
        [self annotateLiquorLocations:_lStoreArray withCategory:@"lStore"];
    } else {
        [self removePinTypes:@"lStore"];
        lStorePinsoff=true;
        [self cancelAnnimationForRow:0 inSection:1];
    }
}

-(void) checkSClubs {
    if (_lStoreArray.count == 0 || _lStoreArray == nil || _barsArray.count == 0 || _barsArray == nil || _sClubArray.count == 0 || _sClubArray == nil) {
        NSLog(@"no data, pulling LL data");
        [self getLLInfo:@"sClub"];
    } else {
        NSLog(@"have bLL data, showing sClubs");
        [self showSClub];
    }
}

- (void)showSClub {
    if (stripClubPinsOff) {
        stripClubPinsOff=false;
        [self annotateLiquorLocations:_sClubArray withCategory:@"stripclub"];
    } else {
        [self removePinTypes:@"stripclub"];
        stripClubPinsOff=true;
    }
}

-(void) checkMurder {
    if (_crimeArray.count == 0 || _crimeArray == nil) {
        NSLog(@"no crime data, get crime data");
        [self getCrimeInfo:@"murder"];
    } else {
        NSLog(@"yes crime data, display murder");
        [self ShowMurder];
    }
}

- (void)ShowMurder {
    if (murderPinsoOff) {
        murderPinsoOff=false;
        [self annotateMurderLocations];
    } else {
        [self removePinTypes:@"murder"];
        murderPinsoOff=true;
        [self cancelAnnimationForRow:4 inSection:2];
    }
}

-(void) checkDisorderly {
    if (_crimeArray.count == 0 || _crimeArray == nil) {
        NSLog(@"no crime data, get crime data");
        [self getCrimeInfo:@"disorderly"];
    } else {
        NSLog(@"yes crime data, display disorderly");
        [self ShowDisorderlyConduct];
    }
}

- (void)ShowDisorderlyConduct {
    if (drunkPinsOff) {
        drunkPinsOff=false;
        [self annotateDisorderlyConductLocations];
    }else {
        [self removePinTypes:@"disorderlyconduct"];
        drunkPinsOff=true;
        [self cancelAnnimationForRow:3 inSection:2];
    }
}

-(void) checkAssault {
    if (_crimeArray.count == 0 || _crimeArray == nil) {
        NSLog(@"no crime data, get crime data");
        [self getCrimeInfo:@"assault"];
    } else {
        NSLog(@"yes crime data, display assault");
        [self ShowAssault];
    }
}

- (void)ShowAssault {
    if (assaultPinsOff) {
        assaultPinsOff=false;
        [self annotateAssaultLocations];
    } else {
        [self removePinTypes:@"assault"];
        assaultPinsOff=true;
        [self cancelAnnimationForRow:1 inSection:2];
    }
}

-(void) checkaggAssault {
    if (_crimeArray.count == 0 || _crimeArray == nil) {
        NSLog(@"no crime data, get crime data");
        [self getCrimeInfo:@"aggAssault"];
    } else {
        NSLog(@"yes crime data, display aggAssault");
        [self ShowAggAssault];
    }
}

- (void)ShowAggAssault {
    if (aggassaultPinsOff) {
        aggassaultPinsOff=false;
        [self annotateAGGAssaultLocations];
    } else {
        [self removePinTypes:@"aggassault"];
        aggassaultPinsOff=true;
        [self cancelAnnimationForRow:2 inSection:2];
    }
}

-(void) checkArson {
    if (_crimeArray.count == 0 || _crimeArray == nil) {
        NSLog(@"no crime data, get crime data");
        [self getCrimeInfo:@"arson"];
    } else {
        NSLog(@"yes crime data, display arson");
        [self ShowArson];
    }
}

- (void)ShowArson {
    if (arsonPinsOff) {
        arsonPinsOff=false;
        [self annotateArsonLocations];
    } else {
        [self removePinTypes:@"arson"];
        arsonPinsOff=true;
        [self cancelAnnimationForRow:0 inSection:2];
    }
}

-(void)checkProperty0 {
    if (_propertyArray.count == 0 || _propertyArray == nil) {
        NSLog(@"no prop data, pulling prop data");
        [self getPropertyInfo:(@"prop0")];
    } else {
        NSLog(@"found data, displaying prop0");
        [self ShowProperty0];
    }
}

-(void) ShowProperty0 {
    if (property0PinsOff) {
        property0PinsOff = false;
        [self annotatePropertyLocations];
        [self propertyLabelsOn];
    }else {
        property0PinsOff = true;
        [self removePinTypes:@"p0"];
        [self propertyLabelsOff];
        [self cancelAnnimationForRow:0 inSection:3];
    }
}

-(void)checkProperty1 {
    if (_propertyArray.count == 0 || _propertyArray == nil) {
        NSLog(@"no prop data, pulling prop data");
        [self getPropertyInfo:(@"prop1")];
    } else {
        NSLog(@"found data, displaying prop1");
        [self ShowProperty1];
    }
}

-(void) ShowProperty1 {
    if (property1PinsOff) {
        property1PinsOff = false;
        [self annotatePropertyLocations1];
        [self propertyLabelsOn];
    }else {
        property1PinsOff = true;
        [self removePinTypes:@"p1"];
        [self propertyLabelsOff];
        [self cancelAnnimationForRow:1 inSection:3];
    }
}

-(void)checkProperty2 {
    if (_propertyArray.count == 0 || _propertyArray == nil) {
        NSLog(@"no prop data, pulling prop data");
        [self getPropertyInfo:(@"prop2")];
    } else {
        NSLog(@"found data, displaying prop2");
        [self ShowProperty2];
    }
}

-(void) ShowProperty2 {
    if (property2PinsOff) {
        property2PinsOff = false;
        [self annotatePropertyLocations2];
        [self propertyLabelsOn];
    }else {
        property2PinsOff = true;
        [self removePinTypes:@"p2"];
        [self propertyLabelsOff];
        [self cancelAnnimationForRow:2 inSection:3];
    }
}

-(void)checkProperty3 {
    if (_propertyArray.count == 0 || _propertyArray == nil) {
        NSLog(@"no prop data, pulling prop data");
        [self getPropertyInfo:(@"prop3")];
    } else {
        NSLog(@"found data, displaying prop3");
        [self ShowProperty3];
    }
}

-(void) ShowProperty3 {
    if (property3PinsOff) {
        property3PinsOff = false;
        [self annotatePropertyLocations3];
        [self propertyLabelsOn];
    }else {
        property3PinsOff = true;
        [self removePinTypes:@"p3"];
        [self propertyLabelsOff];
        [self cancelAnnimationForRow:3 inSection:3];
    }
}

-(void)checkProperty4 {
    if (_propertyArray.count == 0 || _propertyArray == nil) {
        NSLog(@"no prop data, pulling prop data");
        [self getPropertyInfo:(@"prop4")];
    } else {
        NSLog(@"found data, displaying prop4");
        [self ShowProperty4];
    }
}

-(void) ShowProperty4 {
    if (property4PinsOff) {
        property4PinsOff = false;
        [self annotatePropertyLocations4];
        [self propertyLabelsOn];
    }else {
        property4PinsOff = true;
        [self removePinTypes:@"p4"];
        [self propertyLabelsOff];
        [self cancelAnnimationForRow:4 inSection:3];
    }
}

#pragma mark - Map Methods

-(void) propertyLabelsOn {
    [UIView animateWithDuration:0.5 animations:^{
        [_lowMoneyLabel setAlpha:0.8];
        [_highMoneyLabel setAlpha:0.8];
        [_propertyPriceImageView setAlpha:1.0];
        [self.view layoutIfNeeded];
    }];
}

-(void) propertyLabelsOff {
    if (property4PinsOff && property3PinsOff && property2PinsOff && property1PinsOff && property0PinsOff) {
        [UIView animateWithDuration:0.5 animations:^{
            [_lowMoneyLabel setAlpha:0.0];
            [_highMoneyLabel setAlpha:0.0];
            [_propertyPriceImageView setAlpha:0.0];
            [self.view layoutIfNeeded];
        }];
    }
}

-(void) startAnnimationForRow:(int)row inSection:(int)section {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
    CustomCollectionViewCell *cell = (CustomCollectionViewCell *)[_menuCollectionView cellForItemAtIndexPath:indexPath];
    [cell.activityIndicator startAnimating];
}

-(void) cancelAnnimationForRow:(int)row inSection:(int)section {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
    CustomCollectionViewCell *cell = (CustomCollectionViewCell *)[_menuCollectionView cellForItemAtIndexPath:indexPath];
    [cell.activityIndicator stopAnimating];
}

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
            [renderer setFillColor:[UIColor redColor]];
            [renderer setAlpha:0.6];
        } else if ([currentCircle.circleType isEqualToString:@"aggassault"]) {
            [renderer setFillColor:[UIColor darkGrayColor]];
            [renderer setAlpha:0.6];
        }else if ([currentCircle.circleType isEqualToString:@"assault"]) {
            [renderer setFillColor:[UIColor grayColor]];
            [renderer setAlpha:0.6];
        }else if ([currentCircle.circleType isEqualToString:@"disorderlyconduct"]) {
            [renderer setFillColor:[UIColor brownColor]];
            [renderer setAlpha:0.6];
        }else if ([currentCircle.circleType isEqualToString:@"murder"]) {
            [renderer setFillColor:[UIColor blackColor]];
            [renderer setAlpha:1.0];
        } else if ([currentCircle.circleType isEqualToString:@"p0"]) {
            [renderer setFillColor:[UIColor colorWithRed:0/255. green: 255/255. blue: 0/255. alpha:0.7]];
        } else if ([currentCircle.circleType isEqualToString:@"p1"]) {
            [renderer setFillColor:[UIColor colorWithRed:0/244. green:204/255. blue:0/255. alpha:0.7]];
        } else if ([currentCircle.circleType isEqualToString:@"p2"]) {
            [renderer setFillColor:[UIColor colorWithRed:0/255. green:153/255. blue:0/255. alpha:0.7]];
        } else if ([currentCircle.circleType isEqualToString:@"p3"]) {
            [renderer setFillColor:[UIColor colorWithRed:0/255. green:102/255. blue:0/255. alpha:0.7]];
        } else if ([currentCircle.circleType isEqualToString:@"p4"]) {
            [renderer setFillColor:[UIColor colorWithRed:0/255. green:51/255. blue:0/255. alpha:0.7]];
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
        }
        return pinView;
    }
    return nil;
}

-(void) geocodeProperties {
    for (Property *prop in _propertyArray) {
        
        NSString *address = [NSString stringWithFormat:@"%@, Detroit, United States", prop.propAddress];
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder geocodeAddressString: address completionHandler:^(NSArray* placemarks, NSError* error){
            
            for (CLPlacemark* aPlacemark in placemarks) {
                prop.propLat = [NSString stringWithFormat:@"%.7f",aPlacemark.location.coordinate.latitude];
                prop.propLon = [NSString stringWithFormat:@"%.7f",aPlacemark.location.coordinate.longitude];
                NSLog(@"%@ coords %@,%@",prop.propAddress,prop.propLat, prop.propLon);
            }
        }];
    }
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
    [self cancelAnnimationForRow:0 inSection:0];
    [self zoomToPins];
}

-(IBAction)sliderchanged:(UISlider *)slider {
    float(policeArea) = (_policeAreaSlider.value * 6000);
    float(miles) = (policeArea / 1609.344);
    NSLog(@"Slider Changed: %f, %f", policeArea, _policeAreaSlider.value);
    _policeRadiusLabel.text = ([NSString stringWithFormat:@"Police Radius: %1.2f mi",miles]);
    for (id<MKOverlay> annot in _mapView.overlays){
        if ([annot isKindOfClass:[MKCircle class]]) {
            MyCircle *overlay = (MyCircle *)annot;
            if ([overlay.circleType isEqualToString:@"police"]) {
                [_mapView removeOverlay:overlay];
                MyCircle *newOverlay = [MyCircle circleWithCenterCoordinate:overlay.coordinate radius:policeArea];
                newOverlay.circleType =@"police";
                [_mapView addOverlay:newOverlay level:MKOverlayLevelAboveRoads];
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
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    CustomCollectionViewCell *cell = (CustomCollectionViewCell *)[_menuCollectionView cellForItemAtIndexPath:indexPath];
    [cell.activityIndicator stopAnimating];
    
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
    [self cancelAnnimationForRow:0 inSection:1];
    [self cancelAnnimationForRow:1 inSection:1];
    [self zoomToPins];
}

#pragma mark - Annotate Property Methods

- (void)annotatePropertyLocations {
    [self startAnnimationForRow:0 inSection:3];
    for (Property *loc in _propertyArray) {
        if (loc.propPrice.intValue <= 10000) {
            CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([loc.propLat floatValue], [loc.propLon floatValue]);
            MyPointAnnotation *pa1 = [[MyPointAnnotation alloc] init];
            pa1.coordinate = coord;
            MyCircle *cirlce = [MyCircle circleWithCenterCoordinate:pa1.coordinate radius:150];
            cirlce.circleType=@"p0";
            [_mapView addOverlay:cirlce level:MKOverlayLevelAboveRoads];
        }
    }
    [self cancelAnnimationForRow:0 inSection:3];
}

- (void)annotatePropertyLocations1 {
    [self startAnnimationForRow:1 inSection:3];
    for (Property *loc in _propertyArray) {
        if (loc.propPrice.intValue >10000 && loc.propPrice.intValue <= 30000) {
            CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([loc.propLat floatValue], [loc.propLon floatValue]);
            MyPointAnnotation *pa1 = [[MyPointAnnotation alloc] init];
            pa1.coordinate = coord;
            MyCircle *cirlce = [MyCircle circleWithCenterCoordinate:pa1.coordinate radius:150];
            cirlce.circleType=@"p1";
            [_mapView addOverlay:cirlce level:MKOverlayLevelAboveRoads];
        }
    }
    [self cancelAnnimationForRow:1 inSection:3];
}

- (void)annotatePropertyLocations2 {
    [self startAnnimationForRow:2 inSection:3];
    for (Property *loc in _propertyArray) {
        if (loc.propPrice.intValue > 30000 && loc.propPrice.intValue <=70000) {
            CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([loc.propLat floatValue], [loc.propLon floatValue]);
            MyPointAnnotation *pa1 = [[MyPointAnnotation alloc] init];
            pa1.coordinate = coord;
            MyCircle *cirlce = [MyCircle circleWithCenterCoordinate:pa1.coordinate radius:150];
            cirlce.circleType=@"p2";
            [_mapView addOverlay:cirlce level:MKOverlayLevelAboveRoads];
        }
    }
    [self cancelAnnimationForRow:2 inSection:3];
}

- (void)annotatePropertyLocations3 {
    [self startAnnimationForRow:3 inSection:3];
    for (Property *loc in _propertyArray) {
        if (loc.propPrice.intValue >70000 && loc.propPrice.intValue <=125000) {
            CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([loc.propLat floatValue], [loc.propLon floatValue]);
            MyPointAnnotation *pa1 = [[MyPointAnnotation alloc] init];
            pa1.coordinate = coord;
            MyCircle *cirlce = [MyCircle circleWithCenterCoordinate:pa1.coordinate radius:150];
            cirlce.circleType=@"p3";
            [_mapView addOverlay:cirlce level:MKOverlayLevelAboveRoads];
        }
    }
    [self cancelAnnimationForRow:3 inSection:3];
}

- (void)annotatePropertyLocations4 {
    [self startAnnimationForRow:4 inSection:3];
    for (Property *loc in _propertyArray) {
        if (loc.propPrice.intValue >125000) {
            CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([loc.propLat floatValue], [loc.propLon floatValue]);
            MyPointAnnotation *pa1 = [[MyPointAnnotation alloc] init];
            pa1.coordinate = coord;
            MyCircle *cirlce = [MyCircle circleWithCenterCoordinate:pa1.coordinate radius:150];
            cirlce.circleType=@"p4";
            [_mapView addOverlay:cirlce level:MKOverlayLevelAboveRoads];
        }
    }
    [self cancelAnnimationForRow:4 inSection:3];
}

#pragma mark - Annotate Crime Methods

- (void)annotateMurderLocations {
    for (Crime *loc in _crimeArray) {
        if ([loc.crimeClass isEqualToString:@"09001"] || [loc.crimeClass isEqualToString:@"09002"] || [loc.crimeClass isEqualToString:@"09003"] ||[loc.crimeClass isEqualToString:@"09004"]) {
            CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([loc.lat floatValue], [loc.lon floatValue]);
            MyPointAnnotation *pa1 = [[MyPointAnnotation alloc] init];
            pa1.coordinate = coord;
            MyCircle *cirlce = [MyCircle circleWithCenterCoordinate:pa1.coordinate radius:150];
            cirlce.circleType=@"murder";
            [_mapView addOverlay:cirlce level:MKOverlayLevelAboveRoads];
        }
    }
    [self cancelAnnimationForRow:4 inSection:2];
}

- (void)annotateDisorderlyConductLocations {
    [self startAnnimationForRow:3 inSection:2];
    for (Crime *loc in _crimeArray) {
        if ([loc.crimeClass isEqualToString:@"53002"] || [loc.crimeClass isEqualToString:@"53001"]) {
            CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([loc.lat floatValue], [loc.lon floatValue]);
            MyPointAnnotation *pa1 = [[MyPointAnnotation alloc] init];
            pa1.coordinate = coord;
            MyCircle *cirlce = [MyCircle circleWithCenterCoordinate:pa1.coordinate radius:150];
            cirlce.circleType=@"disorderlyconduct";
            [_mapView addOverlay:cirlce level:MKOverlayLevelAboveRoads];
        }
    }
    [self cancelAnnimationForRow:3 inSection:2];
}

- (void)annotateAssaultLocations {
    [self startAnnimationForRow:1 inSection:2];
    for (Crime *loc in _crimeArray) {
        if ([loc.crimeClass isEqualToString:@"13001"]) {
            CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([loc.lat floatValue], [loc.lon floatValue]);
            MyPointAnnotation *pa1 = [[MyPointAnnotation alloc] init];
            pa1.coordinate = coord;
            MyCircle *cirlce = [MyCircle circleWithCenterCoordinate:pa1.coordinate radius:150];
            cirlce.circleType=@"assault";
            [_mapView addOverlay:cirlce level:MKOverlayLevelAboveRoads];
        }
    }
    [self cancelAnnimationForRow:1 inSection:2];
}

- (void)annotateAGGAssaultLocations {
    [self startAnnimationForRow:2 inSection:2];
    for (Crime *loc in _crimeArray) {
        if ([loc.crimeClass isEqualToString:@"13002"]) {
            CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([loc.lat floatValue], [loc.lon floatValue]);
            MyPointAnnotation *pa1 = [[MyPointAnnotation alloc] init];
            pa1.coordinate = coord;
            MyCircle *cirlce = [MyCircle circleWithCenterCoordinate:pa1.coordinate radius:150];
            cirlce.circleType=@"aggassault";
            [_mapView addOverlay:cirlce level:MKOverlayLevelAboveRoads];
        }
    }
    [self cancelAnnimationForRow:2 inSection:2];
}

- (void)annotateArsonLocations {
    [self startAnnimationForRow:0 inSection:2];
    for (Crime *loc in _crimeArray) {
        if ([loc.crimeClass isEqualToString:@"20000"]) {
            CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([loc.lat floatValue], [loc.lon floatValue]);
            MyPointAnnotation *pa1 = [[MyPointAnnotation alloc] init];
            pa1.coordinate = coord;
            MyCircle *cirlce = [MyCircle circleWithCenterCoordinate:pa1.coordinate radius:150];
            cirlce.circleType=@"arson";
            [_mapView addOverlay:cirlce level:MKOverlayLevelAboveRoads];
        }
    }
    [self cancelAnnimationForRow:0 inSection:2];
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
}

-(void)searchResultRecv:(NSNotification *)notification {
    [self geocodeProperties];
}

# pragma mark - Life Cycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    _hostName = @"data.detroitmi.gov";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachablityChanged:) name:kReachabilityChangedNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showPolice) name:@"policeDataRcvMsg" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showFire) name:@"fireDataRcvMsg" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showBars) name:@"barDataRcvMsg" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showLStore) name:@"lStoreDataRcvMsg" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showSClub) name:@"sClubDataRcvMsg" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ShowArson) name:@"arsonDataRcvMsg" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ShowAssault) name:@"assaultDataRcvMsg" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ShowAggAssault) name:@"aggAssaultDataRcvMsg" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ShowDisorderlyConduct) name:@"disorderlyDataRcvMsg" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ShowMurder) name:@"murderDataRcvMsg" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ShowProperty0) name:@"prop0DataRcvMsg" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ShowProperty1) name:@"prop1DataRcvMsg" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ShowProperty2) name:@"prop2DataRcvMsg" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ShowProperty3) name:@"prop3DataRcvMsg" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ShowProperty4) name:@"prop4DataRcvMsg" object:nil];
    
    hostReach = [Reachability reachabilityWithHostname:_hostName];
    [hostReach startNotifier];
    
    internetReach = [Reachability reachabilityForInternetConnection];
    [internetReach startNotifier];
    
    wifiReach = [Reachability reachabilityForLocalWiFi];
    [wifiReach startNotifier];
    
    MKCoordinateRegion region = [_mapView regionThatFits:MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(42.4, -83.09), 50000, 50000)];
    [_mapView setRegion:region animated:YES];
    
    _policeArray = [[NSMutableArray alloc] init];
    _propertyArray = [[NSMutableArray alloc] init];
    _unusedArray = [[NSMutableArray alloc] init];
    _lStoreArray = [[NSMutableArray alloc] init];
    _barsArray = [[NSMutableArray alloc] init];
    _crimeArray = [[NSMutableArray alloc] init];
    _fireArray = [[NSMutableArray alloc] init];
    _sClubArray = [[NSMutableArray alloc] init];
    
    _menuCollectionView.layer.cornerRadius = 8.0;
    [_policeAreaSlider setAlpha:0.0];
    [_policeRadiusLabel setAlpha:0.0];
    [_lowMoneyLabel setAlpha:0.0];
    [_highMoneyLabel setAlpha:0.0];
    [_propertyPriceImageView setAlpha:0.0];
    
    
    _publicServicesArray = @[@"Police", @"Fire"];
    _liquorTypeArray = @[@"Liquor Stores", @"Bars/Restaurants"]; //, @"Strip Clubs"];
    _crimeActsArray = @[@"Arson", @"Assault", @"Aggrevated Assault", @"Disorderly Conduct", @"Murder"];
    _publicServicesIconsArray = @[@"Police", @"Fire"];
    _liquorTypeIconsArray = @[@"LiquorStores", @"BarsRestaurants"]; //, @"StripClubs"];
    _crimeActsIconsArray = @[@"Arson", @"Assault", @"AggrevatedAssault", @"DisorderlyConduct", @"Murder"];
    _propertiesSoldArray = @[@"<$10k",@"<$30k",@"<$70k",@"<$125k",@"$125+"];
    _propertyIconsArray = @[@"Home",@"Home",@"Home",@"Home",@"Home"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"out of memory");
}

@end
