//
//  ContentViewModel.swift
//  BugTrackingSystem
//
//  Created by iPHTech 40 on 06/08/26.
//
import Observation

@Observable
class ContentViewModel {
    var isAdmin:Bool { SessionManager.shared.isAdmin }
}
