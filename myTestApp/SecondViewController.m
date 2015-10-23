//
//  SecondViewController.m
//  myTestApp
//
//  Created by Denis Fromfontan on 22.10.15.
//  Copyright © 2015 Denis Fromfontan. All rights reserved.
//

#import "SecondViewController.h"
#import "Order.h"
#import <MapKit/MapKit.h>
#import "MyAnnotation.h"
@interface SecondViewController () <MKMapViewDelegate> {
    NSMutableData *_downloadedData;
    NSMutableArray *Orders;
    
}
@property(weak,nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.mapView.delegate = self;
    Orders = [[NSMutableArray alloc] init];
    
    
    NSString *urlString = @"http://mobapply.com/tests/orders/";
    
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [request setTimeoutInterval:30.0f];
    
    [request setHTTPMethod:@"GET"];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if([data length]>0 && error ==nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self parseResponse:data];
            });
        } else if([data length] == 0 && error == nil) {
            NSLog(@"Пустой ответ");
        } else if(error) {
            NSLog(@"error");
        }
    }];
    
    
}

-(void)parseResponse:(NSData*)data {
    NSError *error=nil;
    
    NSArray *jsonObjects = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    
    if(jsonObjects!=nil && error==nil && [jsonObjects isKindOfClass:[NSArray class]]) {
        
        for(int i=0; i<jsonObjects.count;i++) {
            NSDictionary *dict = [jsonObjects objectAtIndex:i];
            if([dict isKindOfClass:[NSDictionary class]]) {
                
                
                Order *newOrder = [[Order alloc] init];
                newOrder.departureAddress = [dict objectForKey:@"departureAddress"];
                newOrder.destinationAddress = [dict objectForKey:@"destinationAddress"];
                
                [Orders addObject:newOrder];
                
            } else {
                NSLog(@"Ошибка");
            }
        }
        
        
    }
    
    dispatch_queue_t backgroundQueue = dispatch_queue_create("com.mycompany.myqueue", 0);
    
    dispatch_async(backgroundQueue, ^{
        [self googleRequest:0];
        [self googleRequest:1];
    });
    
   
    
}

-(void)googleRequest:(int)direction {
    if(Orders.count>0) {
        [self showPoint:[Orders objectAtIndex:0] direction:direction];
        
        for(int i = 1; i<Orders.count; i++) {
            
            [self showPoint:[Orders objectAtIndex:i] direction:direction];
            
        }
        
    }
    
}


-(void)showPoint:(Order*)newOrder direction:(int)direction{
    NSString *country ;
    NSString *zipCode;
    NSString *city;
    NSString *countryCode;
    //            NSString *street;
    //            NSString *houseNumber;
    if(direction==0) {
        country = [newOrder.departureAddress objectForKey:@"country"];
        zipCode = [newOrder.departureAddress objectForKey:@"zipCode"];
        city = [newOrder.departureAddress objectForKey:@"city"];
        countryCode  = [newOrder.departureAddress objectForKey:@"countryCode"];
    } else {
        country = [newOrder.destinationAddress objectForKey:@"country"];
        zipCode = [newOrder.destinationAddress objectForKey:@"zipCode"];
        city = [newOrder.destinationAddress objectForKey:@"city"];
        countryCode  = [newOrder.destinationAddress objectForKey:@"countryCode"];
    }
    
    
    NSString *address=[NSString stringWithFormat:@"%@+%@+%@+%@",city,country,countryCode,zipCode];
    
    NSString *lookUpString = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?address=%@&sensor=false", address];
    lookUpString = [lookUpString stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    
    NSURL *url = [NSURL URLWithString:[lookUpString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
    
    NSError *error;
    
    NSData *jsonResponse = [NSData dataWithContentsOfURL:url options:NSDataReadingUncached error:&error];
    
    
    if(jsonResponse.length<1000) {
        address=[NSString stringWithFormat:@"%@",city];
        
        lookUpString = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?address=%@&sensor=false", address];
        lookUpString = [lookUpString stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        
        url = [NSURL URLWithString:[lookUpString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
        
    }
    
    jsonResponse = [NSData dataWithContentsOfURL:url options:NSDataReadingUncached error:&error];
    
    if(jsonResponse.length<100) {
        NSLog(@"Позиция не найдена: %@",lookUpString);
        return;
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [request setTimeoutInterval:30.0f];
    
    [request setHTTPMethod:@"GET"];
    
    //            NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    
    
    NSURLResponse *response = nil;
    NSData *data;
    while(data.length<1000) {
        NSLog(@"%lu  %@",(unsigned long)data.length, url);
        data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
    }
    if(direction==0) {
        [self parseGoogle:data color:@"green"];
    } else {
        [self parseGoogle:data color:@"red"];
    }
    NSLog(@"%lu", (unsigned long)data.length);
    
    
}



-(void)parseGoogle:(NSData*)data color:(NSString*)color {
    NSError *error;
    
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    NSArray *locationArray = [[[jsonDict valueForKey:@"results"] valueForKey:@"geometry"] valueForKey:@"location"];
    if(locationArray.count>0) {
        locationArray = [locationArray objectAtIndex:0];
        NSString *latitudeString = [locationArray valueForKey:@"lat"];
        NSString *longitudeString = [locationArray valueForKey:@"lng"];
        NSLog(@"LatitudeString:%@ & LongitudeString:%@ \n\n\n", latitudeString, longitudeString);
        
        
        CLLocationCoordinate2D c;
        c.latitude = [latitudeString floatValue];
        c.longitude = [longitudeString floatValue];
        
        MyAnnotation *annotation = [[MyAnnotation alloc] init];
        annotation.coordinate = c;
        annotation.color=color;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.mapView addAnnotation:annotation];
        });
        
       
        
    }
}


- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(MyAnnotation *)annotation
{
    
    
    
    static NSString *annotationIdentifier = @"AnnotationIdentifier";
    
    MKPinAnnotationView *pinView = (MKPinAnnotationView *) [mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
    
    if (!pinView) {
        pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationIdentifier] ;
        
        if ([annotation.color isEqualToString:@"red"]) {
            [pinView setPinColor:MKPinAnnotationColorRed];
        } else {
            [pinView setPinColor:MKPinAnnotationColorGreen];
        }
        
        pinView.animatesDrop = YES;
        pinView.canShowCallout = YES;
        
       
    } else {
        pinView.annotation = annotation;
    }
    
    return pinView; 
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
