//
//  ChartViewController.swift
//  RoomDentist
//
//  Created by LDH on 2021/10/23.
//

import UIKit
import SnapKit
import Charts
import Alamofire

class ChartViewController: UIViewController {

    var days: [String] = []
    var values: [Double] = []
    var uid: String = ""
    
    lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = "최근 7일 충치 개수 분석"
        titleLabel.textColor = UIColor(named: "Brown")!
        titleLabel.font = UIFont(name: "GmarketSansBold", size: CGFloat(17))
        return titleLabel
    }()
    
    lazy var noticeLabel: UILabel = {
        let noticeLabel = UILabel()
        noticeLabel.text = "서버에서 불러오는 중..."
        noticeLabel.textColor = UIColor(named: "Brown")!
        noticeLabel.font = UIFont(name: "GmarketSansBold", size: CGFloat(15))
        return noticeLabel
    }()
    
    lazy var barChartView: BarChartView = {
        let chartView = BarChartView()
        return chartView
    }()
    
    lazy var exitButton: UIButton = {
        let exitButton = UIButton()
        exitButton.layer.cornerRadius = 10
        exitButton.backgroundColor = UIColor(named: "SignatureBlack")
        exitButton.setTitleColor(.white, for: .normal)
        exitButton.setTitle("뒤로 가기", for: .normal)
        exitButton.titleLabel?.font = UIFont(name: "GmarketSansBold", size: CGFloat(17))
        exitButton.addTarget(self, action: #selector(prevPageEvent), for: .touchUpInside)
        return exitButton
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        configureUI()
        postData(uid: uid)
        
        barChartView.noDataText = "데이터가 없습니다."
        barChartView.noDataFont = .systemFont(ofSize: 20)
        barChartView.noDataTextColor = .lightGray
        barChartView.legend.textColor = UIColor(named: "SignatureBlack")!
        barChartView.xAxis.labelTextColor = UIColor(named: "SignatureBlack")!
        barChartView.data?.setValueTextColor(UIColor(named: "SignatureBlack")!)
        setChart(dataPoints: days, values: values)
        
    }
    
    @objc func prevPageEvent() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func configureUI() {
        
        self.view.addSubview(titleLabel)
        self.view.addSubview(barChartView)
        self.view.addSubview(noticeLabel)
        self.view.addSubview(self.exitButton)
        
        self.titleLabel.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(20)
            $0.centerX.equalTo(self.view.safeAreaLayoutGuide.snp.centerX)
        }
        
        self.barChartView.snp.makeConstraints {
            $0.top.equalTo(self.titleLabel.snp.bottom).offset(20)
            $0.left.right.equalTo(self.view.safeAreaLayoutGuide).inset(10)
            $0.bottom.equalTo(self.exitButton.snp.top).offset(-20)
        }
        
        self.noticeLabel.snp.makeConstraints {
            $0.centerX.equalTo(self.barChartView.snp.centerX)
            $0.centerY.equalTo(self.barChartView.snp.centerY)
        }
        
        self.exitButton.snp.makeConstraints {
            $0.bottom.equalTo(self.view).inset(20)
            $0.right.equalTo(self.view.safeAreaLayoutGuide.snp.right).inset(20)
            $0.left.equalTo(self.view.safeAreaLayoutGuide.snp.left).inset(20)
            $0.height.equalTo(45)
        }
        
    }
    
    func setChart(dataPoints: [String], values: [Double]) {
        var dataEntries: [BarChartDataEntry] = []
        for i in 0..<dataPoints.count {
            let dataEntry = BarChartDataEntry(x: Double(i), y: values[i])
            dataEntries.append(dataEntry)
        }

        let chartDataSet = BarChartDataSet(entries: dataEntries, label: "충치 개수")
        chartDataSet.barBorderColor = UIColor(named: "SignatureBlack")!
        chartDataSet.valueColors = ChartColorTemplates.colorful()
        chartDataSet.valueFont = UIFont(name: "GmarketSansBold", size: CGFloat(17))!

        // 차트 컬러
        chartDataSet.colors = [UIColor(named: "RoomYellow")!]
        barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: dataPoints)
        barChartView.xAxis.labelTextColor = UIColor(named: "SignatureBlack")!
        barChartView.xAxis.labelFont = UIFont(name: "GmarketSansMedium", size: CGFloat(10))!
        barChartView.xAxis.gridColor = .clear
        barChartView.xAxis.axisLineColor = .clear
        barChartView.barData?.setValueTextColor(UIColor(named: "SignatureBlack")!)
        
        // 데이터 삽입
        let chartData = BarChartData(dataSet: chartDataSet)
        barChartView.data = chartData
        
        
        barChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
        chartDataSet.colors = ChartColorTemplates.colorful()
    }
    
    // MARK: uid Flask 서버로 전송
    func postData(uid: String) {
        let url = "https://roomdentist.tunahouse97.com/Charts"
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 10
        
        // POST 로 보낼 정보
        let params = ["uid": "\(uid)"] as Dictionary
        
        // httpBody 에 parameters 추가
        do {
            try request.httpBody = JSONSerialization.data(withJSONObject: params, options: [])
        } catch {
            print("http Body Error")
        }
        
        AF.request(request).responseJSON { (response) in
            switch response.result {
                case .success(let value):
                    do {
                        let data = try JSONSerialization.data(withJSONObject: value, options: .prettyPrinted)
                        let json = try JSONDecoder().decode(Result.self, from: data)
                        DispatchQueue.main.async { [self] in
                            self.days = json.date
                            self.values = json.cavityValue.map({ Double($0)! })
                            self.barChartView.reloadInputViews()
                            self.barChartView.notifyDataSetChanged()
                            self.barChartView.data?.notifyDataChanged()
                            noticeLabel.textColor = .clear
                            setChart(dataPoints: self.days, values: self.values)
                            print("확인")
                        }
                    } catch(let err) {
                        print(err.localizedDescription)
                    }
                case .failure(let err):
                    print(err.localizedDescription)
            }
        }
    }
}

struct Result: Codable {
    let date, cavityValue: [String]
}
