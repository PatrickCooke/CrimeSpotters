//
//  BarsRestaurants.m
//  CrimeSpotters
//
//  Created by Patrick Cooke on 5/6/16.
//  Copyright © 2016 Patrick Cooke. All rights reserved.
//

#import "BarsRestaurants.h"

@implementation BarsRestaurants

- (id) initWithName:(NSString *)name andpermitType:(NSString *)permitType andLat:(NSString *)lat andlon:(NSString *)lon andaddress:(NSString *)address andcity:(NSString *)city andzip:(NSString *)zip andactive:(NSString *)active {
    self = [super init];
    if (self) {
        self.name = name;
        self.permitType = permitType;
        self.Lat = lat;
        self.Lon = lon;
        self.address = address;
        self.city = city;
        self.zip = zip;
        self.active = active;
    }
    return self;
}
@end
