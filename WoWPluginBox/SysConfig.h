//
//  SysConfig.h
//  cpsdna
//
//  Created by 黄 时欣 on 13-11-7.
//  Copyright 黄 时欣 2013年. All rights reserved.
//

#define kBASE_URL @"http://wowbox.duowan.com/wowplugin/"
#define kADDONSUPDATER_URL ([kBASE_URL stringByAppendingString:@"AddonsUpdater.json"])

#define kBIGFOOT_BASE_URL @"http://wow.bfupdate.178.com/BigFoot/"
#define kBIGFOOT_CHECKSUM ([kBIGFOOT_BASE_URL stringByAppendingString:@"checksum.txt"])
#define kBIGFOOT_FILELIST ([kBIGFOOT_BASE_URL stringByAppendingString:@"Interface/3.1/filelist.xml.z"])

#define kMOGU_INFO_URL @"http://wow.jdbbx.com/wowver/Info.txt"
#define kMOGU_PlUGINLIST_URL @"http://wow.jdbbx.com/soft/xml/pluglist.xml"

#define kEUI_XML_URL @"http://www.eui.cc/wow/eui.xml"

#define kVER_CHECK @"https://raw.githubusercontent.com/hohaiuhsx/WoWPluginBox/master/wpb_ver_check.json"
