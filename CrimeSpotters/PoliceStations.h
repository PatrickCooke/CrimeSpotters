//
//  PoliceStations.h
//  CrimeSpotters
//
//  Created by Patrick Cooke on 5/5/16.
//  Copyright © 2016 Patrick Cooke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PoliceStations : NSObject

@property (nonatomic, strong) NSString *pAddress;
@property (nonatomic, strong) NSString *pCaptainName;
@property (nonatomic, strong) NSString *pLat;
@property (nonatomic, strong) NSString *pLon;
@property (nonatomic, strong) NSString *pCity;
@property (nonatomic, strong) NSString *pState;
@property (nonatomic, strong) NSString *pPrecinct;

-(id) initWithPAddress: (NSString *)pAddress andCaptainName: (NSString *)pCaptainName andLatitude: (NSString *)pLat andLongitude: (NSString *)pLon andCity: (NSString *)pCity andState: (NSString *)pState andPrecinct: (NSString *)pPrecinct;

@end
