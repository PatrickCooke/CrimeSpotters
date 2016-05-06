//
//  PoliceStations.m
//  CrimeSpotters
//
//  Created by Patrick Cooke on 5/5/16.
//  Copyright © 2016 Patrick Cooke. All rights reserved.
//

#import "PoliceStations.h"

@implementation PoliceStations

-(id) initWithPAddress:(NSString *)pAddress andCaptainName:(NSString *)pCaptainName andLatitude:(NSString *)pLat andLongitude:(NSString *)pLon andCity:(NSString *)pCity andState:(NSString *)pState andPrecinct:(NSString *)pPrecinct{
    self = [super init];
    if (self) {
        self.pAddress = pAddress;
        self.pCaptainName = pCaptainName;
        self.pLat = pLat;
        self.pLon = pLon;
        self.pCity = pCity;
        self.pState = pState;
        self.pPrecinct = pPrecinct;
    }
    return self;
}

@end
