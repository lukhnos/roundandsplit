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

class AboutViewController : UITableViewController, MFMailComposeViewControllerDelegate {
    let detailCellId = "DetailCell"
    let linkCellId = "LinkCell"
    let settingCellId = "SettingCell"
    let versionCellId = "VersionCell"

    let aboutSectionTitles = [
        Utilities.L("Version"),
        Utilities.L("Acknowledgments"),
    ]

    let actionableSectionTitles = [
        Utilities.L("Visit Website"),
        Utilities.L("Email Us"),
    ]

    let configSections = [
        (
            Settings.UseDecimalPointKey,
            Utilities.L("Use \".\" for Decimal Point"),
            Utilities.L("By default, the app assumes you are living or traveling in a region where \".\" is used – for example, 9.99. When turned off, it will observe the Region Format settings on your phone.")
        )
    ]

    override func viewDidLoad() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: Utilities.L("Info"), style: UIBarButtonItemStyle.plain, target: nil, action: nil)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2 + configSections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return aboutSectionTitles.count
        } else if section == 1 {
            return actionableSectionTitles.count
        }

        return 1
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section >= 2 {
            let (_, _, text) = configSections[section - 2]
            return text
        }

        return nil
    }

    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 && indexPath.row > 0 {
            return true
        } else if indexPath.section == 1 {
            return true
        }

        return false
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section >= 2 {
            return
        }

        if indexPath.section == 0 && indexPath.row == 1 {
            let file = "Acknowledgments"
            let url = Bundle.main.url(forResource: file, withExtension: "txt")
            var body: String?
            do {
                body = try String(contentsOf: url!, encoding: String.Encoding.utf8)
            } catch _ {
                body = nil
            }
            let title = aboutSectionTitles[indexPath.row]

            let textView = UITextView()
            textView.textContainerInset = UIEdgeInsetsMake(16.0, 10.0, 16.0, 10.0)
            textView.text = body
            textView.isSelectable = false
            textView.isEditable = false
            textView.font = UIFont.systemFont(ofSize: 14)
            textView.textColor = UIColor(red: 109.0/255.0, green: 109.0/255.0, blue: 114.0/255.0, alpha: 1.0)
            textView.backgroundColor = tableView.backgroundColor
            let controller = UIViewController()
            controller.view = textView
            controller.title = title
            navigationController!.pushViewController(controller, animated: true)
        } else if indexPath.section == 1 {
            tableView.deselectRow(at: indexPath, animated: true)

            if indexPath.row == 0 {
                UIApplication.shared.openURL(Constants.WebSiteURL as URL)
            } else {
                if !MFMailComposeViewController.canSendMail() {
                    Utilities.showEmailDisabledAlert(self)
                    return
                }

                let ver = Utilities.bundleShortVersion()
                let addr = Constants.ContactEmail
                let subject = String(format: Utilities.L("Inquiry - Round and Split %@"), ver)
                let controller = MFMailComposeViewController()
                controller.mailComposeDelegate = self
                controller.setSubject(subject)
                controller.setToRecipients([addr])
                present(controller, animated: true, completion: {})
            }
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : UITableViewCell?

        if indexPath.section == 0 {
            if indexPath.row == 0 {
                cell = tableView.dequeueReusableCell(withIdentifier: versionCellId)
                if cell == nil {
                    cell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: versionCellId)
                }
                cell!.detailTextLabel!.text = Utilities.bundleShortVersion()
            } else {
                cell = tableView.dequeueReusableCell(withIdentifier: detailCellId)
                if cell == nil {
                    cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: detailCellId)
                    cell!.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
                }
            }

            let textLabel : UILabel? = cell!.textLabel
            textLabel!.text = aboutSectionTitles[indexPath.row]
        } else if indexPath.section == 1 {
            cell = tableView.dequeueReusableCell(withIdentifier: linkCellId)
            if cell == nil {
                cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: linkCellId)
                let textLabel : UILabel? = cell!.textLabel
                textLabel!.textColor = tableView.tintColor
            }

            let textLabel : UILabel? = cell!.textLabel
            textLabel!.text = actionableSectionTitles[indexPath.row]
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: settingCellId)
            if cell == nil {
                cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: settingCellId)
                let switchButton = UISwitch()
                switchButton.addTarget(self, action: #selector(AboutViewController.switchButtonValueChanged(_:)), for: UIControlEvents.valueChanged)
                cell!.accessoryView = switchButton
            }

            let switchButton = cell!.accessoryView as! UISwitch
            let (key, text, _) = configSections[indexPath.section - 2]
            switchButton.isOn = Settings.boolForKey(key)
            switchButton.tag = indexPath.section - 2

            let textLabel : UILabel? = cell!.textLabel
            textLabel!.text = text
        }

        return cell!
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: {})
    }

    @objc func switchButtonValueChanged(_ switchButton: UISwitch!) {
        let index = switchButton.tag
        let (key, _, _) = configSections[index]
        Settings.setBool(!Settings.boolForKey(key), forKey: key)
    }

    @IBAction func dismissAction() {
        navigationController!.dismiss(animated: true, completion: nil)
    }

}
