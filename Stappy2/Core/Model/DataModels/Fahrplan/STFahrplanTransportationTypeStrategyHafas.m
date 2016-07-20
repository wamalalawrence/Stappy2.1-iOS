//
//  STFahrplanTransportationTypeStrategyHafas.m
//  Stappy2
//
//  Created by Andrej Albrecht on 24.03.16.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import "STFahrplanTransportationTypeStrategyHafas.h"

@implementation STFahrplanTransportationTypeStrategyHafas
-(BOOL)isPedestrian:(NSString*)transportationType
{
    
    
    
    return !transportationType || [transportationType isEqualToString:@""];
}

-(BOOL)isTrain:(NSString*)transportationType
{
    NSArray *trainTypeArray = @[
                                
                                @"ARZ"  //Autoreisezug
                                ,@"AZ"  //AutoZug
                                
                                ,@"CAT"  //City Airport Train
                                ,@"CNL"  //City Night Line
                                ,@"D"  //Schnellzug
                                ,@"DNZ"  //Nacht-Schnellzug
                                ,@"DPF"  //Fernreisezug externer EU
                                ,@"dpn"  //S-Bahn
                                ,@"DPN"  //Nahreisezug
                                ,@"DPS"  //S-Bahn
                                ,@"DZ"  //Sonderzug
                                ,@"e"  //Eilzug
                                ,@"E"  //Eilzug
                                
                                ,@"EC"  //Eurocity
                                ,@"ECB"  //Eurocity
                                ,@"ECW"  //Eurocity
                                ,@"EE"  //Schnellzug
                                ,@"EIC"  //Express InterCity
                                ,@"EM"  //Euromed
                                ,@"EN"  //EuroNight
                                ,@"ENB"  //EuroNight
                                ,@"ER"  //EURegio
                                ,@"ES"  //EuroStar Italia
                                ,@"EST"  //EUROSTAR
                                ,@"EX"  //Express-Zug
                                
                                ,@"HOT"  //Hotelzug
                                ,@"IC"  //Intercity
                                ,@"ICB"  //ÖBB-Intercitybus
                                ,@"ICD"  //IC direct
                                ,@"ICE"  //Intercity-Express
                                ,@"ICF"
                                ,@"ICN"  //InterCityNight
                                ,@"ICr"  //Intercity
                                ,@"ICT"  //Intercity Neigezug
                                ,@"INT"  //Schnellzug
                                ,@"INZ"  //Nachtzug
                                ,@"IP"  //InterPici
                                ,@"IR"  //Interregio
                                ,@"IRE"  //Interregio-Express
                                ,@"IRX"  //Intercity
                                ,@"IXB"  //Intercity-Express
                                ,@"IXK"  //Intercity-Express
                                ,@"IXM"  //ICE MetroRapid
                                ,@"IXP"  //ICE MetroRapid
                                
                                ,@"KD"  //Koleje Dolnoslaskie
                                ,@"KM"  //Osobowy
                                ,@"lt"  //Linien-Taxi
                                ,@"LYN"  //LYNTOG
                                ,@"N"  //Nahverkehrszug
                                ,@"OBU"  //Oberleitungs-Bus
                                ,@"Os"  //Regionalzug
                                ,@"OZ"  //Oeresundzug
                                ,@"PCC"  //PCC Arriva
                                ,@"PPN"  //Osobowy
                                ,@"R"  //Regionalzug
                                ,@"RB"  //Regionalbahn
                                ,@"RE"  //Regional-Express
                                ,@"RER"  //Reseau Express Regional
                                ,@"REX"  //RegionalExpress
                                ,@"rfb"  //Rufbus
                                ,@"RHI"  //Intercity-Express
                                ,@"RHT"  //TGV
                                
                                ,@"RR"  //Schnellzug
                                ,@"RRI"  //Intercity-Express
                                ,@"RRT"  //TGV
                                ,@"RT"  //RegioTram
                                ,@"Rx"  //Schnellzug
                                ,@"R84"  //RegionalExpress
                                ,@"s"  //S-Bahn
                                ,@"S"  //S-Bahn
                                
                                ,@"SC"  //SuperCity
                                
                                ,@"SKM"  //Szybka Kolej Miejska
                                ,@"SKW"  //Szybka Kolej Miejska Warszawa
                                ,@"Sp"  //Eilzug
                                ,@"stb"  //Stadtbahn
                                ,@"Stb"  //Stadtbahn
                                ,@"stR"  //Straßenbahn
                                ,@"Str"  //Straßenbahn
                                ,@"STR"  //Straßenbahn
                                ,@"SWB"  //Schwebebahn
                                ,@"S2"  //Pendolino S220
                                ,@"S84"  //Schnellzug
                                ,@"TER"  //Train Express Regional
                                ,@"TGD"  //TGV Duplex
                                ,@"TGV"  //TGV
                                ,@"THA"  //Thalys
                                ,@"TLG"  //Talgo
                                ,@"TLK"  //Twoje Linie Kolejowe
                                ,@"T84"  //Regionalzug
                                ,@"u"  //U-Bahn
                                ,@"U"  //U-Bahn
                                
                                ,@"UEx"  //Urlaubsexpress
                                ,@"UUU"  //Zug
                                ,@"U70"  //Zug
                                
                                ,@"X70"  //Schnellzug
                                ,@"Zr"  //Eilzug
                                ,@"ZRB"  //Zahnradbahn
                                ,@"ZUG"  //Zug
                                
                                ,@"T"
                                ,@"MT"
                                ,@"ECK"
                                ];
    
    NSArray *lowercaseArray = [trainTypeArray valueForKey:@"lowercaseString"];
    
    NSString *tp = transportationType;
    NSString *tType = [tp lowercaseString];
    
    tType = [[tType componentsSeparatedByCharactersInSet:
              [[NSCharacterSet letterCharacterSet] invertedSet]]
             componentsJoinedByString:@""];
    
    return [lowercaseArray containsObject:tType];
}

-(BOOL)isBus:(NSString*)transportationType
{
    NSArray *busArray = @[
                          @"Bsv"  //Bus
                          ,@"BSV"  //Bus
                          ,@"Bus"  //Bus
                          ,@"BUS"  //Bus
                          ,@"ubu"  //Bus
                          ,@"EB"  //Express-Bus
                          ,@"B"
                          ,@"HVN"
                          ,@"MB"
                          
                          ];
    
    NSArray *lowercaseArray = [busArray valueForKey:@"lowercaseString"];
    
    NSString *tp = transportationType;
    NSString *tType = [tp lowercaseString];
    
    tType = [[tType componentsSeparatedByCharactersInSet:
              [[NSCharacterSet letterCharacterSet] invertedSet]]
             componentsJoinedByString:@""];
    
    return [lowercaseArray containsObject:tType];
}

/*
 ,@"AIR"  //Flugzeug
 ,@"ALS"  //Alaris
 ,@"alt"  //Anruf-Linien-Taxi
 ,@"ALT"  //Anruf-Linien-Taxi
 ,@"ARC"  //Arco/Alvia/Avant
 
 ,@"AS"  //AutoShuttle
 ,@"ast"  //Anruf-Sammel-Taxi
 ,@"AST"  //Anruf-Sammel-Taxi
 ,@"ATB"  //Autoschleuse Tauernbahn
 ,@"ATR"  //Altaria
 ,@"AVE"  //AVE
 
 ,@"EXB"  //IC Bus
 ,@"fae"  //Fähre
 ,@"FAE"  //Fähre
 ,@"FB"  //FernBus
 
 ,@"SCH"  //Schiff
 ,@"SB"  //Seilbahn
 ,@"RJ"  //railjet
 
 ,@"KAT"  //Katamaran
 
 ,@"VIA"  //Viamont
 ,@"WKD"  //Warszawska Kolej Dojazdowa
 ,@"X"  //InterConnex
 ,@"X2"  //X2000
 
 */

@end
