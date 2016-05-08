//
//  FireStations.m
//  CrimeSpotters
//
//  Created by Patrick Cooke on 5/7/16.
//  Copyright © 2016 Patrick Cooke. All rights reserved.
//

#import "FireStations.h"

@implementation FireStations

-(id) initWithStation:(NSString *)station andladder:(NSString *)ladder andlat:(NSString *)lat andLon:(NSString *)lon andBattalion:(NSString *)battalion andEngine:(NSString *)engine {
    self = [super init];
    if (self) {
        self.station = station;
        self.ladder = ladder;
        self.lat = lat;
        self.lon = lon;
        self.battalion = battalion;
        self.engine = engine;
    }
    return self;
}

@end
