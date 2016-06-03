//
//  Property.m
//  CrimeSpotters
//
//  Created by Patrick Cooke on 6/3/16.
//  Copyright © 2016 Patrick Cooke. All rights reserved.
//

#import "Property.h"

@implementation Property

-(id) initWithpropPrice:(NSString *)propPrice andpropClass:(NSString *)propClass andpropAddress:(NSString *)propAddress andpropZip:(NSString *)propZip {
    self = [super init];
    if (self) {
        self.propPrice = propPrice;
        self.propClass = propClass;
        self.propAddress = propAddress;
        self.propZip = propZip;
    }
    return self;
}

@end
