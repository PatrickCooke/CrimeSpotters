//
//  MyPointAnnotation.h
//  CrimeSpotters
//
//  Created by Patrick Cooke on 5/6/16.
//  Copyright © 2016 Patrick Cooke. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface MyPointAnnotation : MKPointAnnotation

@property (nonatomic, strong) NSString *pinType;

@end
