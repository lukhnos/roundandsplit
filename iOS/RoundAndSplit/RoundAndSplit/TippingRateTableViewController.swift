//
//  TippingRateTableViewController.swift
//  RoundAndSplit
//
//  Created by Lukhnos Liu on 11/3/19.
//  Copyright © 2019 Lukhnos Liu. All rights reserved.
//

import UIKit

class TippingRateTableViewController : UITableViewController {

    let cellId = "Rate"
    let rateIndex : Int;

    init(rateIndex: Int) {
        self.rateIndex = rateIndex;
        super.init(style: UITableView.Style.plain)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        switch rateIndex {
        case 0:
            title = Utilities.L("Select the First Rate")
        case 1:
            title = Utilities.L("Select the Second Rate")
        case 2:
            title = Utilities.L("Select the Third Rate")
        default:
            fatalError()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        let currentRateRow = Settings.SupportedTippingRates.firstIndex(of: Settings.tippingRates[rateIndex])!
        tableView.scrollToRow(at: IndexPath(row: currentRateRow, section: 0), at: UITableView.ScrollPosition.none, animated: true)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Settings.SupportedTippingRates.count;
    }

    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if isCurrentlySelectedRate(index: indexPath.row) {
            return nil;
        }
        return indexPath
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let selectedRate = Settings.SupportedTippingRates[indexPath.row]

        var newRates = Settings.tippingRates
        newRates[rateIndex] = selectedRate
        Settings.tippingRates = newRates

        navigationController?.popViewController(animated: true)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : UITableViewCell?

        cell = tableView.dequeueReusableCell(withIdentifier: cellId)
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: cellId)
        }

        cell!.textLabel!.text = Settings.SupportedTippingRates[indexPath.row].percentageString

        if Settings.SupportedTippingRates[indexPath.row] == Settings.tippingRates[rateIndex] {
            cell!.accessoryType = UITableViewCell.AccessoryType.checkmark
            if #available(iOS 13, *) {
                cell!.textLabel!.textColor = UIColor.label
            } else {
                cell!.textLabel!.textColor = UIColor.darkText
            }
        } else {
            if isCurrentlySelectedRate(index: indexPath.row) {
                if #available(iOS 13, *) {
                    cell!.textLabel!.textColor = UIColor.quaternaryLabel
                } else {
                    cell!.textLabel!.textColor = UIColor.lightGray
                }
            } else {
                if #available(iOS 13, *) {
                    cell!.textLabel!.textColor = UIColor.label
                } else {
                    cell!.textLabel!.textColor = UIColor.darkText
                }
            }

            cell!.accessoryType = UITableViewCell.AccessoryType.none
        }

        return cell!
    }

    private func isCurrentlySelectedRate(index: Int) -> Bool {
        for rate in Settings.tippingRates {
            if Settings.SupportedTippingRates[index] == rate {
                return true
            }
        }
        return false
    }
}
