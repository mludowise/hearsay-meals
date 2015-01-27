//
//  Config.swift
//  HearsayMeals
//
//  Created by Mel Ludowise on 11/11/14.
//  Copyright (c) 2014 Mel Ludowise. All rights reserved.
//

import Foundation

let kOfficeTimeZone = NSTimeZone(name: "US/Pacific")
let kGmtTimeZone = NSTimeZone(forSecondsFromGMT: 0)
let kMinDinnerOrders = 4
let kTimeToOrderBy = (hour: 16, minute: 0) // 4pm
let kReportBugAddress = "hearsaymeals-dev@hearsaycorp.com"


let kTesting = false

// Production
let kParseApplicationId = kTesting
    ? "F23K1fxL2OJpfZphfH0lR0Nryz7QCuI1dwIFT6kU"    // mel-hearsaymeals
    : "myq9zbMzdkBqqEyudRcwIR5yxnmwihlslqUvYh34"    // production

let kParseClientKey = kTesting
    ? "8lI3hiHsd8zvm8yTaVLoiBVX4QOfx7tVJyvYG9dS"    // mel-hearsaymeals
    : "sSDcYzwEBOuOGKYjuY28Skvalo2sImKNwXRt7v4q"    // production

let kGoogleClientId = "966122623899-snf8rtjucf08hup8a2jjmihcina16a0j.apps.googleusercontent.com"

let kTeamCalendarId = kTesting
    ? "hearsaycorp.com_0ofjbo5gdaod56rm0u19phdmq4@group.calendar.google.com"    // Lunch Test Calendar
    : "hearsaycorp.com_b8edk8m1lmv57al9uiferecurk@group.calendar.google.com"    // Team Events

