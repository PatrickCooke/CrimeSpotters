//
//  LiquorStore.h
//  CrimeSpotters
//
//  Created by Patrick Cooke on 5/5/16.
//  Copyright © 2016 Patrick Cooke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LiquorStore : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *permitType;
@property (nonatomic, strong) NSString *Lat;
@property (nonatomic, strong) NSString *Lon;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *zip;
@property (nonatomic, strong) NSString *active;

-(id) initWithName: (NSString *)name andpermitType: (NSString *)permitType andLat: (NSString *)lat andlon: (NSString *)lon andaddress: (NSString *)address andcity: (NSString *)city andzip: (NSString *)zip andactive: (NSString *)active;

@end
