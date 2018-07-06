//
//  Constants.swift
//  snapstar
//
//  Created by Nur  on 05/01/2017.
//  Copyright © 2017 SnapStar. All rights reserved.
//


class OCConstant {
    
    static let S3_ACCESS_KEY = "AKIAJY4QJ5V7UPKXDNWQ"
    static let S3_SECRET_KEY = "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"
   
    static let S3_ACCESS_KEY_2 = "AKIAIRIAHC63MF7EEGRQ"
    static let S3_SECRET_KEY_2 = "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"
    
    
    static let SDK_BUNDLE = "com.ourcart.OurCartSDK"
    
    static let DICT_KEY_LANG = "lang"
    
    static let OC_API_KEY_V1 = "e79cf678-5775-491e-a3ad-c45a56508066"
    static let OC_API_KEY_V2 = "91EAD0BFD5363211597128FF344DDA05"
    
    
    static let CONTROLLER_RECEIPT_SNAP = "ReceiptSnap"
    static let CONTROLLER_ONBOARDING = "CameraOnboarding"
    static let CONTROLLER_RECEIPT_HELP = "ReceiptHelp"
    static let CONTROLLER_RECEIPT_REVIEW = "ReceiptReview"
    static let CONTROLLER_RECEIPT_PROGRESS = "ReceiptProgress"
    static let CONTROLLER_RECEIPT_FAILURE = "ReceiptFailure"
    static let CONTROLLER_RECEIPT_SUCCESS = "ReceiptSuccess"
    
    
    
}


enum UrlPaths : String {
    case BASE_URL
    case BASE_URL_DEV
    case URL_PATH_ENABLE_PUSH_NOTIFICATIONS
    case URL_PATH_POST_CASH_OUT
    case URL_PATH_ACCOUNT_STATE
    case URL_PATH_SETTINGS_EULA
    case URL_PATH_SETTINGS_FROM_SERVER
    case URL_PATH_GET_BRANDS_LIST
    case URL_PATH_RECEIPTS_RESULTS
    case URL_PATH_RECEIPTS_CLAIM_STARS
    case URL_PATH_UPLOADED_RECEIPT_TO_S3
    case URL_PATH_ACCOUNTS_SIGNUP
    case URL_PATH_GET_SMS_VERIFICATION_CODE
    case URL_PATH_CONFIRM_SMS_VERIFICATION_CODE
    case URL_PATH_GET_MY_PROMO_CODE_TO_INVITE_FRIENDS
    case URL_PATH_UPGRADE_MINE_APP_VERSION
    case URL_PATH_GET_MY_RECEIPTS_ITEMS
    case URL_PATH_SEND_GOOGLE_VISION_JSON_FOR_VALIDATION
}

enum keys : String {
    case code
    case user
    case items
}

enum defaults : String {
    case LAST_LAUNCHED_APP_VERSION
    case DEVICE_PUSH_TOKEN
    case DEFAULT_KEY_DID_CASH_OUT_AT_LEAST_ONCE
    case DEFAULT_KEY_RECEIPT_UPLOAD_LIMIT_REACHED
    case EULA_SETTINGS
    case GENERAL_SERVER_SETTINGS
    case APP_LAUNCHES_COUNTER
    case SHOULD_SHOW_BRANDS_TUTORIAL_REMOVABLE_BANNER
    case DEFAULT_KEY_DID_UPLOAD_RECEIPT_AT_LEAST_ONCE
    case ONBOARDING_PAGES_VIEWED
    case defaultsKeyUserObject
    case CLICK_OPEN_CAMERA_AT_LEAST_ONCE
    case MY_PROMO_CODE_TO_INVITE_FRIENDS
    case DID_SIGNUP_FROM_INVITE_CODE
    case DID_USE_INVITE_FRIENDS_AT_LEAST_ONCE
    case DID_SHOW_TOOLTIP_FAB
    case DID_SHOW_TOOLTIP_BUY_GET_REWARD
}



enum storyboards : String {
    case MyBrands
    case CashOut
    case GenericWebViewContainer
    case ReceiptAnalyzed
    case ReceiptSnapFlow
    case BurgerMenu
    case SignUpForm
    case Onboarding
    case SmsRegistration
    case CameraOnboarding
    case InviteFriends
    case MyReceipts
}

extension Notification.Name {
    static let DID_CLAIM_STARS_SUCCESSFULLY = Notification.Name("DID_CLAIM_STARS_SUCCESSFULLY")
    static let SHOULD_UPDATE_XP_LEVEL_UI    = Notification.Name("SHOULD_UPDATE_XP_LEVEL_UI")
}



