//
//  AppDelegate.swift
//  open_with_vsc_mac
//
//  Created by 谢渊 on 2021/11/16.
//

import Cocoa
import CoreData
import SwiftUI

// 菜单项
class OwvMenuItem {
    var path: String
    var label: String
    var children: [OwvMenuItem]?
//    var times: Int?
    
    required init(path:String="", label: String="unknow", children:[OwvMenuItem]? = nil) {
        self.path = path
        self.label = label
        self.children = children
//        self.times = times
        
    }
}

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    @IBOutlet weak var menu: NSMenu!
    let userDefault = UserDefaults.standard
    
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    
    let userAccountPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
    
    var customMenuItems = [NSMenuItem]()
    

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        if let button = statusItem.button {
            button.image = NSImage(named: "StatusIcon")
        }
        
        self.readJsonFile()
        
        statusItem.menu = menu
        
        self.setMenuData()
    }
    
    // 读取菜单配置文件
    func readJsonFile() {
        let jsonFilePath = self.userAccountPath[0] + "/menu.json"
        let jsonFileExist = FileManager.default.fileExists(atPath: jsonFilePath)
        let defaultJsonFileContent = "[]"
        var jsonFileContent = ""
        if (jsonFileExist == true) {
            jsonFileContent = try! String(contentsOfFile: jsonFilePath, encoding: String.Encoding.utf8)
        } else {
            FileManager.default.createFile(atPath: jsonFilePath, contents: defaultJsonFileContent.data(using: String.Encoding.utf8), attributes: nil)
            jsonFileContent = defaultJsonFileContent
        }
        
        userDefault.set(jsonFileContent.data(using:.utf8), forKey: "menu_data")
    }
    
    // 设置菜单项
    func setMenuData () {
        let menuData = userDefault.data(forKey: "menu_data")
        
        if(menuData != nil) {
            let data = try? JSONSerialization.jsonObject(with: menuData!, options: JSONSerialization.ReadingOptions.allowFragments) as? [NSDictionary]
            
            data?.forEach{ item in
                let index = data?.firstIndex(of: item) as! Int
                let menuItem = NSMenuItem()
                menuItem.title = item.value(forKey: "label") as! String
                menuItem.action = #selector(self.launcherApp)
                
                statusItem.menu?.insertItem(menuItem, at: index)
                self.customMenuItems.append(menuItem)
            }
        }
    }
    @objc func launcherApp(_ menuitem: NSMenuItem) {
        // 这里的path 我也不想重新算 主要是action不会传参数
        let menuData = userDefault.data(forKey: "menu_data")
        var path = ""
        
        if(menuData != nil) {
            let data = try? JSONSerialization.jsonObject(with: menuData!, options: JSONSerialization.ReadingOptions.allowFragments) as? [NSDictionary]
            
            data?.forEach{item in
                if(item.value(forKey: "label") as! String == menuitem.title)
                {
                    path = item.value(forKey: "path") as! String
                }
            }
            
            let insiderMenuItem = menu.item(withTitle: "配置")?.submenu?.item(withTitle: "Insiders")
            var appname = ""
            
            if(insiderMenuItem?.state == NSControl.StateValue.on) {
                appname = "/usr/local/bin/code-insiders"
            } else {
                appname = "/usr/local/bin/code"
            }
            
            let task = Process()
            task.launchPath = appname
            var enviroment = ProcessInfo.processInfo.environment
            enviroment["PATH"] = "/usr/local/bin:/usr/bin:/bin:/usr/sinb:/sbin"
            task.environment = enviroment
            task.arguments = [path]
//            task.arguments = ["-v"]
            task.launch()
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    
    // 关闭应用
    @IBAction func quitApp(_ sender: Any) {
        NSApplication.shared.terminate(self)
    }
    
    // 切换常用开关
    @IBAction func switchFrequentlyUsed(_ sender: Any) {
        let frequentlyUsed = menu.item(withTitle: "配置")?.submenu?.item(withTitle: "常用")
        
        if(frequentlyUsed?.state == NSControl.StateValue.on) {
            frequentlyUsed?.state = NSControl.StateValue.off
        } else {
            frequentlyUsed?.state = NSControl.StateValue.on
        }
    }
    
    // 是否使用的是vscode - insider版本
    @IBAction func switchInsiders(_ sender: Any) {
        let insiderMenuItem = menu.item(withTitle: "配置")?.submenu?.item(withTitle: "Insiders")
        
        if(insiderMenuItem?.state == NSControl.StateValue.on) {
            insiderMenuItem?.state = NSControl.StateValue.off
        } else {
            insiderMenuItem?.state = NSControl.StateValue.on
        }
    }
    
    // swift不知道怎么监听文件变化 只能设置一个重新加载的选项
    @IBAction func reload(_ sender: Any) {
        self.customMenuItems.forEach{customMenuItem in
            statusItem.menu?.removeItem(customMenuItem)
        }
        self.customMenuItems = []
        self.readJsonFile()
        self.setMenuData()
    }
    
    // 打开菜单配置文件
    @IBAction func configureMenu(_ sender: Any) {
        let jsonFilePath = self.userAccountPath[0] + "/menu.json"
        let nw = NSWorkspace()
        nw.openFile(jsonFilePath)
    }
}

//
//class ConfigurationWindowController<RootView: View>: NSWindowController {
//    convenience init(rootView: RootView) {
//        let hostingController = NSHostingController(rootView: rootView.frame(width: 600, height: 400))
//        let window = NSWindow(contentViewController: hostingController)
//        window.setContentSize(NSSize(width: 600, height: 400))
//        self.init(window: window)
//    }
//}
//
//struct ConfigurationView:View {
//    var body: some View {
//        VStack {
//            Spacer()
//            Text("我是新窗口")
//            Spacer()
//        }
//    }
//}
