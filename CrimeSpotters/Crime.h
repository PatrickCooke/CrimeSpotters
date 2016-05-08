//
//  Crime.h
//  CrimeSpotters
//
//  Created by Patrick Cooke on 5/6/16.
//  Copyright © 2016 Patrick Cooke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Crime : NSObject

@property (nonatomic, strong) NSString *category;
@property (nonatomic, strong) NSString *crimeClass;
@property (nonatomic, strong) NSString *lat;
@property (nonatomic, strong) NSString *lon;
@property (nonatomic, strong) NSString *date;

-(id) initWithCategory: (NSString *)category andCrimeClass: (NSString *)crimeClass andLat: (NSString *)lat andLon: (NSString *)lon andDate:(NSString *)date;

@end
