//
//  FireStations.h
//  CrimeSpotters
//
//  Created by Patrick Cooke on 5/7/16.
//  Copyright © 2016 Patrick Cooke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FireStations : NSObject

@property (nonatomic, strong) NSString *station;
@property (nonatomic, strong) NSString *ladder;
@property (nonatomic, strong) NSString *lat;
@property (nonatomic, strong) NSString *lon;
@property (nonatomic, strong) NSString *battalion;
@property (nonatomic, strong) NSString *engine;

- (id) initWithStation:(NSString *)station andladder:(NSString *)ladder andlat:(NSString *)lat andLon:(NSString *)lon andBattalion:(NSString *)battalion andEngine:(NSString *)engine;



@end
