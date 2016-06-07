//
//  Property.h
//  CrimeSpotters
//
//  Created by Patrick Cooke on 6/3/16.
//  Copyright © 2016 Patrick Cooke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Property : NSObject

@property (nonatomic, strong) NSString *parcelNumber;
@property (nonatomic, strong) NSString *propPrice;
@property (nonatomic, strong) NSString *propClass;
@property (nonatomic, strong) NSString *propAddress;
@property (nonatomic, strong) NSString *propZip;
@property (nonatomic, strong) NSString *propLat;
@property (nonatomic, strong) NSString *propLon;

-(id) initWithpropPrice: (NSString *)propPrice andpropClass: (NSString *)propClass andpropAddress: (NSString *)propAddress andpropZip: (NSString *)propZip andparcelNumber:(NSString *)parcelNumber andpropLat:(NSString *)propLat andpropLon:(NSString *)propLon;

@end
