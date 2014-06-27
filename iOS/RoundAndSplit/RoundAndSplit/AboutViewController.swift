//
// Copyright (c) 2014 Lukhnos Liu.
// 
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
// DEALINGS IN THE SOFTWARE.
//

import UIKit
import MessageUI

class AboutViewController : UITableViewController, UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate {
    let detailCellId = "DetailCell"
    let linkCellId = "LinkCell"
    let settingCellId = "SettingCell"
    let versionCellId = "VersionCell"

    let aboutSectionTitles = [
        Utilities.L("Version"),
        Utilities.L("Acknowledgments"),
        Utilities.L("Disclaimer"),
    ]

    let actionableSectionTitles = [
        Utilities.L("Visit Website"),
        Utilities.L("Email Us"),
    ]

    let configSections = [
        (
            Settings.UseDecimalPointKey,
            Utilities.L("Use \".\" for Decimal Point"),
            Utilities.L("By default, the app assumes you are living or traveling in a region where \".\" is used – for example, 9.99. If turned off, it will observe the Region Format settings on your phone.")
        )
    ]

    override func viewDidLoad() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: Utilities.L("Info"), style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2 + configSections.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return aboutSectionTitles.count
        } else if section == 1 {
            return actionableSectionTitles.count
        }

        return 1
    }

    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section >= 2 {
            var (_, _, text) = configSections[section - 2]
            return text
        }

        return nil
    }

    override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.section == 0 && indexPath.row > 0 {
            return true
        } else if indexPath.section == 1 {
            return true
        }

        return false
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section >= 2 {
            return
        }

        if indexPath.section == 0 {
            var file : String
            if indexPath.row == 1 {
                file = "Acknowledgments"
            } else {
                file = "Disclaimer"
            }
            var url = NSBundle.mainBundle().URLForResource(file, withExtension: "txt")
            var body = NSString(contentsOfURL: url!, encoding: NSUTF8StringEncoding, error: nil)
            var title = aboutSectionTitles[indexPath.row]

            var textView = UITextView()
            textView.textContainerInset = UIEdgeInsetsMake(16.0, 10.0, 16.0, 10.0)
            textView.text = body
            textView.selectable = false
            textView.editable = false
            textView.font = UIFont.systemFontOfSize(14)
            textView.textColor = UIColor(red: 109.0/255.0, green: 109.0/255.0, blue: 114.0/255.0, alpha: 1.0)
            textView.backgroundColor = tableView.backgroundColor
            var controller = UIViewController()
            controller.view = textView
            controller.title = title
            navigationController!.pushViewController(controller, animated: true)
        } else if indexPath.section == 1 {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)

            if indexPath.row == 0 {
                UIApplication.sharedApplication().openURL(Constants.WebSiteURL)
            } else {
                if !MFMailComposeViewController.canSendMail() {
                    Utilities.showEmailDisabledAlert()
                    return
                }

                let ver = Utilities.bundleShortVersion()
                let addr = Constants.ContactEmail
                let subject = NSString(format: Utilities.L("Inquiry - Round and Split %@"), ver)
                let controller = MFMailComposeViewController()
                controller.mailComposeDelegate = self
                controller.setSubject(subject)
                controller.setToRecipients([addr])
                presentViewController(controller, animated: true, completion: {})
            }
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell : UITableViewCell?

        if indexPath.section == 0 {
            if indexPath.row == 0 {
                cell = tableView.dequeueReusableCellWithIdentifier(versionCellId) as? UITableViewCell
                if cell == nil {
                    cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: versionCellId)
                }
                cell!.detailTextLabel!.text = Utilities.bundleShortVersion()
            } else {
                cell = tableView.dequeueReusableCellWithIdentifier(detailCellId) as? UITableViewCell
                if cell == nil {
                    cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: detailCellId)
                    cell!.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
                }
            }

            cell!.textLabel!.text = aboutSectionTitles[indexPath.row]
        } else if indexPath.section == 1 {
            cell = tableView.dequeueReusableCellWithIdentifier(linkCellId) as? UITableViewCell
            if cell == nil {
                cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: linkCellId)
                cell!.textLabel!.textColor = tableView.tintColor
            }

            cell!.textLabel!.text = actionableSectionTitles[indexPath.row]
        } else {
            cell = tableView.dequeueReusableCellWithIdentifier(settingCellId) as? UITableViewCell
            if cell == nil {
                cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: settingCellId)
                var switchButton = UISwitch()
                switchButton.addTarget(self, action: Selector("switchButtonValueChanged:"), forControlEvents: UIControlEvents.ValueChanged)
                cell!.accessoryView = switchButton
            }

            var switchButton = cell!.accessoryView as UISwitch
            var (key, text, _) = configSections[indexPath.section - 2]
            switchButton.on = Settings.boolForKey(key)
            switchButton.tag = indexPath.section - 2

            cell!.textLabel!.text = text
        }

        return cell!
    }

    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        controller.dismissViewControllerAnimated(true, completion: {})
    }

    func switchButtonValueChanged(switchButton: UISwitch!) {
        var index = switchButton.tag
        var (key, text, _) = configSections[index]
        Settings.setBool(!Settings.boolForKey(key), forKey: key)
    }

    @IBAction func dismissAction() {
        navigationController!.dismissViewControllerAnimated(true, completion: nil)
    }

}
