//
//  XCTestWDMonkeyController.swift
//  FastMonkey
//
//  fixed by zhangzhao on 2017/7/17.
//

import Foundation
import XCTest

/**
    Extension using the public XCTest API to generate
    events.
*/
@available(iOS 9.0, *)
extension Monkey {
    /// Generates a random `CGVector` inside the frame of the app.
    public func randomOffset() -> CGVector {
        let point = randomPoint()
        return CGVector(dx: point.x, dy: point.y)
    }

    /**
        Add an action that checks, at a fixed interval,
        if an alert is being displayed, and if so, selects
        a random button on it.

        - parameter interval: How often to generate this
          event. One of these events will be generated after
          this many randomised events have been generated.
        - parameter application: The `XCUIApplication` object
          for the current application.
    */
    public func addXCTestTapAlertAction(interval: Int, application: XCUIApplication) {
        addAction(interval: interval) { [weak self] in
            // The test for alerts on screen and dismiss them if there are any.
            //            for i in 0 ..< application.alerts.count {
            //                let alert = application.alerts.element(boundBy: i)
            //                let buttons = alert.descendants(matching: .button)
            //                XCTAssertNotEqual(buttons.count, 0, "No buttons in alert")
            //                let index = UInt(self!.r.randomUInt32() % UInt32(buttons.count))
            //                let button = buttons.element(boundBy: index)
            //                button.tap()
            //            }
            //usleep(2000000)
            //let isRunning = application.running
            //let current = Int(XCTestWDFindElementUtils.getAppPid())
            //if current == 0 {
            //    return
            //}
            if application.state == XCUIApplication.State.runningForeground {
                for i in 0 ..< application.alerts.count {
                    let alert = application.alerts.element(boundBy: i)
                    let buttons = alert.descendants(matching: .button)
                    XCTAssertNotEqual(buttons.count, 0, "No buttons in alert")
                    let index = self!.r.randomInt(lessThan: buttons.count)
                    //let index: Int = Int(self!.r.randomUInt32() % UInt32(buttons.count))
                    let button = buttons.element(boundBy: index)
                    button.tap()
                }
            }else{
                application.activate()
                self!.sleep(5)
                self?.pid = Int(XCTestWDFindElementUtils.getAppPid())
            }
        }
    }
    
    public func addDefaultXCTestPublicActions(app: XCUIApplication) {
        addXCTestPublicTapAction(app: app, weight: 50)
        addXCTestPublicLongPressAction(app: app, weight: 1)
        addXCTestPublicDragAction(app: app, weight: 10)
    }
    
    /// Add an action that generates a tap, with a possibility for double taps, using the public XCTest API.
    /// - Parameter app: The application proxy.
    /// - Parameter weight: The relative probability of this event being generated. Can be any value larger than zero. Probabilities
    /// will be normalised to the sum of all relative probabilities.
    /// - Parameter doubleTapProbability: Probability that a double tap event is used. Between 0 and 1.
    public func addXCTestPublicTapAction(app: XCUIApplication,
                                         weight: Double,
                                         doubleTapProbability: Double = 0.05) {
        addAction(weight: weight) { [unowned self] in
            let doubleTap = self.r.randomDouble() < doubleTapProbability
            let coordinate = app.coordinate(withNormalizedOffset: .zero).withOffset(self.randomOffset())
            
            if doubleTap {
                coordinate.doubleTap()
            } else {
                coordinate.tap()
            }
        }
    }
    
    /// Add an action that generates a long press event using the public XCTest API.
    /// - Parameter app: The application proxy.
    /// - Parameter weight: The relative probability of this event being generated. Can be any value larger than zero. Probabilities
    /// will be normalised to the sum of all relative probabilities.
    public func addXCTestPublicLongPressAction(app: XCUIApplication,
                                               weight: Double) {
        addAction(weight: weight) { [unowned self] in
            let coordinate = app.coordinate(withNormalizedOffset: .zero).withOffset(self.randomOffset())
            coordinate.press(forDuration: 0.5)
        }
    }
    
    /// Add an action that generates a drag event from one random screen position to another using the public XCTest API.
    /// - Parameter app: The application proxy.
    /// - Parameter weight: The relative probability of this event being generated. Can be any value larger than zero. Probabilities
    /// will be normalised to the sum of all relative probabilities.
    public func addXCTestPublicDragAction(app: XCUIApplication,
                                          weight: Double) {
        addAction(weight: weight) { [unowned self] in
            let startCoordinate = app.coordinate(withNormalizedOffset: .zero).withOffset(self.randomOffset())
            let endCoordinate = app.coordinate(withNormalizedOffset: .zero).withOffset(self.randomOffset())
            startCoordinate.press(forDuration: 0.2, thenDragTo: endCoordinate)
        }
    }
    
    /**
     Add an action that checks current app, at a fixed interval,
     if app is not running , so launch app
     */
    
    public func addXCTestCheckCurrentApp(interval:Int, application:XCUIApplication) {
        addCheck(interval:interval){ [weak self] in
            //let work = DispatchWorkItem(qos:.userInteractive){
                /** too slow **/
                //application._waitForQuiescence()
            //    let isRunning = application.running
            //    let current = Int(XCTestWDFindElementUtils.getAppPid())
            //    if current != self?.pid || !isRunning{
            //        application.launch()
            //        self?.sleep(5)
            //        self?.pid = Int(XCTestWDFindElementUtils.getAppPid())
            //    }
            //}
            //DispatchQueue.main.async(execute:work)
            let work = DispatchWorkItem(qos:.userInteractive){
                if (application.state != XCUIApplication.State.runningForeground){
                    application.activate()
                    self?.sleep(5)
                    self?.pid = Int(XCTestWDFindElementUtils.getAppPid())
                }
            }
            DispatchQueue.main.async(execute:work)
        }
    }
    
    /**
     Add an action that check login keypoint, at a fixed interval,
     if find key point, take login event
     */

    public func addXCTestAppLogin(interval:Int, application:XCUIApplication) {
        addAction(interval:interval){ [weak self] in
            do{
                let session = try XCTestWDSessionManager.singleton.checkDefaultSession()
                let root = session.application
                if root != nil{
                    let usage = "xpath"
                    let tag = "//XCUIElementTypeOther[@name='登录']/XCUIElementTypeTextField"
                    let element = try? XCTestWDFindElementUtils.filterElement(usingText: usage, withvalue: tag, underElement: root!)
                    if let element = element {
                        if element != nil {
                            self?.addXCTestLoginAction(application: application)
                        }
                        else{
                            return
                        }
                    }
                }
            }catch{
                return
            }
        }
    }
}

