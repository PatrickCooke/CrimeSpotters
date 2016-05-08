//
//  Crime.m
//  CrimeSpotters
//
//  Created by Patrick Cooke on 5/6/16.
//  Copyright © 2016 Patrick Cooke. All rights reserved.
//

#import "Crime.h"

@implementation Crime

-(id) initWithCategory:(NSString *)category andCrimeClass:(NSString *)crimeClass andLat:(NSString *)lat andLon:(NSString *)lon andDate:(NSString *)date {
    self = [super init];
    if (self) {
        self.category = category;
        self.crimeClass = crimeClass;
        self.lat = lat;
        self.lon = lon;
        self.date = date;
    }
    return self;
}

@end
