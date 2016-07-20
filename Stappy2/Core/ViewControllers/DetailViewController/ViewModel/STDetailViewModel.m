//
//  STDetailViewModel.m
//  Stappy2
//
//  Created by Pavel Nemecek on 22/05/16.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import "STDetailViewModel.h"
#import "STRequestsHandler.h"
#import "StLocalDataArchiever.h"
#import "STEventsModel.h"
#import "STStartModel.h"
#import "NSDate+DKHelper.h"
#import "STParkHausModel.h"
#import "STAngeboteModel.h"
#import "STAppSettingsManager.h"

@implementation STDetailViewModel

-(instancetype)initWithModel:(id)model{
   
    self = [super init];
    if (self) {
        self.model = model;
        self.headline = [self headlineString];
        self.content = [self contentString];
        
        if (self.content && self.content.length>0) {
            self.content = [self.content stringByTrimmingCharactersInSet:
                            [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        }
        
    
        
        self.coverImageUrl = [self coverImageURL];
        self.couponDescription = [self couponString];
        self.address = [self addressString];
        SEL subtitleSelector = NSSelectorFromString(@"subtitle");

        if ([model respondsToSelector:subtitleSelector] &&!self.content.length) {
            self.content =[model valueForKey:@"subtitle"];
        }
        
        SEL hoursSelector = NSSelectorFromString(@"openinghours2");
        SEL imagesSelector = NSSelectorFromString(@"images");
        SEL backgroundSelector = NSSelectorFromString(@"background");
        SEL isOfferSelector = NSSelectorFromString(@"isOffer");
        SEL phoneSelector = NSSelectorFromString(@"phone");
        SEL websiteSelector = NSSelectorFromString(@"contactUrl");
        SEL emailSelector = NSSelectorFromString(@"email");
        SEL websiteParkingSelector = NSSelectorFromString(@"website");
        SEL latitudeSelector = NSSelectorFromString(@"latitude");
        SEL longitudeSelector = NSSelectorFromString(@"longitude");

        SEL startDateSelector = NSSelectorFromString(@"startDate");
        SEL endDateSelector = NSSelectorFromString(@"endDate");
        

        
        SEL endDatStringeHourSelector = NSSelectorFromString(@"endDateHourString");
        SEL endDateStringSelector = NSSelectorFromString(@"endDateString");
        SEL startDateHourStringSelector = NSSelectorFromString(@"startDateHourString");
        SEL startDateStringSelector = NSSelectorFromString(@"startDateString");

        if([model respondsToSelector:endDatStringeHourSelector]) {
            self.endDateHourString = [model valueForKey:@"endDateHourString"];
        }
        
        if([model respondsToSelector:endDatStringeHourSelector]) {
            self.endDateHourString = [model valueForKey:@"endDateHourString"];
        }
        
        if([model respondsToSelector:endDateStringSelector]) {
            self.endDateString = [model valueForKey:@"endDateString"];
        }
        if([model respondsToSelector:startDateHourStringSelector]) {
            self.startDateHourString = [model valueForKey:@"startDateHourString"];
        }
        if([model respondsToSelector:startDateStringSelector]) {
            self.startDateString = [model valueForKey:@"startDateString"];
        }

        if([model respondsToSelector:startDateSelector]) {
            self.startDate = [model valueForKey:@"startDate"];
            
        }
        if([model respondsToSelector:endDateSelector]) {
            self.endDate = [model valueForKey:@"endDate"];
            
        }
        if([model respondsToSelector:latitudeSelector]) {
            self.latitude = [[model valueForKey:@"latitude"] doubleValue];
        }
        
        if([model respondsToSelector:longitudeSelector]) {
            self.longitude = [[model valueForKey:@"longitude"] doubleValue];
        }

        if ([model respondsToSelector:phoneSelector]) {
            self.phone = [model valueForKey:@"phone"];
        }
        if ([model respondsToSelector:emailSelector]) {
            self.email = [model valueForKey:@"email"];
        }
        
        if ([model respondsToSelector:websiteSelector]) {
            self.contactUrl =  [[model valueForKey:@"contactUrl"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        }
        if ([model respondsToSelector:websiteParkingSelector]) {
            self.contactUrl =  [[model valueForKey:@"website"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        }
        
        if ([model respondsToSelector:imagesSelector]) {
            self.images = [model valueForKey:@"images"];
        }
        
        if ([model respondsToSelector:hoursSelector]) {
            self.openingHours = [model valueForKey:@"openinghours2"];
        }
        
        if ([model respondsToSelector:backgroundSelector]) {
            self.background = [model valueForKey:@"background"];
        }
        
        if ([model respondsToSelector:isOfferSelector]) {
            self.offer = [[model valueForKey:@"isOffer"] boolValue];
        }
        
        if ([model conformsToProtocol:@protocol(Favoritable)]) {
            self.favoritable = YES;
            self.favorite = [[StLocalDataArchiever sharedArchieverManager] isFavorite:((STMainModel<Favoritable> *)model)];
        }
        
        if ([model respondsToSelector:@selector(dateToShow)] && [(STMainModel*)model dateToShow].length ) {
            NSString* textDate = [[[(STMainModel*)model dateToShow] componentsSeparatedByString:@" "] componentsJoinedByString:@" | "];
            //the date comes in different formats for different components(with and without hour) for some reason
            
            NSString*dateToShowString = [(STMainModel*)model dateToShow];
            
            NSDate* dateToShow;
            dateToShow = [NSDate dateFromString:dateToShowString format:@"dd.MM.yyyy HH:mm"];
            if (!dateToShow) {
                dateToShow = [NSDate dateFromString:dateToShowString format:@"dd.MM.yyyy"];
            }
            
            if([UIScreen mainScreen].bounds.size.height <= 568.0)
            {
                self.date = [NSString stringWithFormat:@"%@",textDate];
                
            }
            else{
               self.date = [NSString stringWithFormat:@"%@, den %@",[dateToShow dayName],textDate];
                
            }
        }
       
        if ([model isKindOfClass:[STEventsModel class]]) {
           self.category = [(STEventsModel*)model secondaryKey];
        }
        if ([model isKindOfClass:[STStartModel class]]) {
            self.category = [(STStartModel*)model secondaryKey];
        }
        if ([model isKindOfClass:[STAngeboteModel class]]) {
            self.category = [(STAngeboteModel*)model mainKey];
        }
        
        if ([model respondsToSelector:@selector(openingTimes)] &&
            [model valueForKey:@"openingTimes"] != nil) {
            
            NSString *data = [model valueForKey:@"openingTimes"];
            if ([model respondsToSelector:@selector(rates)] &&
                [model valueForKey:@"rates"] != nil) {
                data = [data stringByAppendingString:[model valueForKey:@"rates"]];
            }
            
            NSString* css  = @"<style media=\"screen\" type=\"text/css\">\n"
            "body {\n"
            " \tmargin:0px;padding:8px; background:transparent\n"
            "}\n"
            "td {\n"
            "\tfont-family: 'Helvetica Neue', Helvetica, Arial, sans-serif;\n"
            "\tfont-size:8pt;\t\n"
            "\tborder:1px solid white;\t\n"
            "\tpadding:8px;\n"
            "\tcolor:white;\n"
            "}\n"
            "table {\n"
            "\twidth:100%;\n"
            "    border-spacing: 0px;\n"
            "    border-collapse: collapse;\t\n"
            "}\n"
            "\n"
            "</style>";
            self.openingTimes = [NSString stringWithFormat:@"<html><head>%@</head><body>%@%@</html></body>",css, [model valueForKey:@"openingTimes"],[model valueForKey:@"rates"]];
        }
        
        if ([model isKindOfClass:[STAngeboteModel class]] && [[STAppSettingsManager sharedSettingsManager] showCoupons]) {
            self.offer = YES;
        }
    }
    return self;
}

- (NSURL*)coverImageURL {
    NSString *imageString = nil;
    NSURL*returnedCoverImageURL = nil;
    SEL selector = NSSelectorFromString(@"image_url");

    if ([self.model respondsToSelector:@selector(image)] && ([[self.model valueForKey:@"image"] length] > 0)) {
        imageString = [self.model valueForKey:@"image"];
        
         if ([self.model respondsToSelector:@selector(background)]) {
             NSString*background = [self.model valueForKey:@"background"];
             if (background.length>0) {
                 imageString = background;
             }
         }
        if (imageString.length>0) {
              returnedCoverImageURL = [[STRequestsHandler sharedInstance] buildImageUrl:imageString];
        }
    }
    else if ([self.model respondsToSelector:selector]) {
        imageString = [self.model valueForKey:@"image_url"];
        
        if (imageString.length>0) {
            returnedCoverImageURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.parkinghq.com/%@", imageString]];
        }
    }
    return returnedCoverImageURL;
}

- (NSString*)headlineString {
    NSString * returnedTitle;
    
    SEL nameSelector = NSSelectorFromString(@"name");

    
    if ([self.model respondsToSelector:@selector(title)]) {
        returnedTitle = [self.model valueForKey:@"title"];
    }
    if([self.model respondsToSelector:nameSelector]) {
        returnedTitle = [self.model valueForKey:@"name"];
    }
    return returnedTitle;
}

- (NSString*)addressString {
    NSString * returnedAddress;
    SEL selector = NSSelectorFromString(@"street1");

    if ([self.model respondsToSelector:@selector(address)]) {
        returnedAddress = [self.model valueForKey:@"address"];
    } else if ([self.model respondsToSelector:selector]) {
        returnedAddress = [self.model valueForKey:@"street1"];
    }
    return returnedAddress;
}

- (NSString*)contentString {
    NSString * returnedString;
    if ([self.model respondsToSelector:@selector(body)]) {
        returnedString = [self.model valueForKey:@"body"];
    }
    return returnedString;
}

- (NSString*)couponString {
    NSString * returnedString;
    SEL selector = NSSelectorFromString(@"body2");
    if ([self.model respondsToSelector:selector]) {
        returnedString = [self.model valueForKey:@"body2"];
    }
    return returnedString;
}

@end
