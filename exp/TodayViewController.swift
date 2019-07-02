import UIKit
import CoreData

class TodayViewController: UIViewController {
    
    var summ1 = 0.0
    var datFrom = NSDate()
    var datTo = NSDate()
    var currancyarr = [(symbol: String, code: String)]()
//    var ctfd = CurrencyWork()
//    var arcu = [(Currency, Bool)]()
    
    @IBOutlet weak var todayButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buttonCurrency()
    }
    
    /*проверяет, сколько транзакций с разными валютами за сегодня
     если 1 - то считает сумму
     если больше - то рисует кнопки для разных валют и считает*/
    func logic() {
        if countOfCurrencyToday().count == 1 {
            calculate(cur: currencyFromCode(code: countOfCurrencyToday()[0]))
        } else {
            for i in countOfCurrencyToday() {
                //currencyFromCode(code: i)
                print(i)
            }
        }
    }
    
    //возвращает массив валют, которые были использованы сегодня(первые 3)
    func countOfCurrencyToday() -> [String] {
        var arrayOfCurrency = [String]()
        var calendar = Calendar.current
        calendar.timeZone = NSTimeZone.local
        
        let dateFrom = calendar.startOfDay(for: Date()) as NSDate
        let dateTo = calendar.date(byAdding: .day, value: 1, to: dateFrom as Date)! as NSDate
        
        let fromPredicate = NSPredicate(format: "date >= %@", dateFrom)
        let toPredicate = NSPredicate(format: "date < %@", dateTo)
        let datePredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [fromPredicate, toPredicate])
        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Payment")

        request.resultType = .dictionaryResultType
        request.propertiesToFetch = ["currency"]
        request.returnsObjectsAsFaults = false
        request.propertiesToGroupBy = ["currency"]
        
        request.predicate = datePredicate
        do {
            let objects = try! CoreDataManager.instance.managedObjectContext.fetch(request)
            for i in objects as! [[String: Any]] {
                let dd = try! CoreDataManager.instance.managedObjectContext.existingObject(with: i["currency"] as! NSManagedObjectID)
                if arrayOfCurrency.count < 3 {
                    arrayOfCurrency.append((dd as! Currency).code ?? "")
                }
            }
        }
        return arrayOfCurrency
    }
    
    //возвращаеь класс Currency по коду валюы
    func currencyFromCode(code: String) -> Currency {
        let toPredicate = NSPredicate(format: "code = %@", code)
        let datePredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [toPredicate])
        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Currency")
        
        request.predicate = datePredicate
        do {
            let objects = try! CoreDataManager.instance.managedObjectContext.fetch(request)
            return objects[0] as! Currency
        }
    }
    
    //считает сумму за сегодня по определенной валюте
    func calculate(cur: Currency) {
        var calendar = Calendar.current
        calendar.timeZone = NSTimeZone.local
        
        let dateFrom = calendar.startOfDay(for: Date()) as NSDate
        let dateTo = calendar.date(byAdding: .day, value: 1, to: dateFrom as Date)! as NSDate
        
        
        let fromPredicate = NSPredicate(format: "date >= %@", dateFrom)
        let toPredicate = NSPredicate(format: "date < %@", dateTo)
        let predicate = NSPredicate(format: "currency == %@", cur)
        let datePredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [fromPredicate, toPredicate, predicate])
        
        datFrom = dateFrom
        datTo = dateTo
        
        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Payment")
        request.predicate = datePredicate
        do {
            let objects = try! CoreDataManager.instance.managedObjectContext.fetch(request)
            var summ = 0.0
            for object in objects as! [Payment] {
                summ  += object.count
            }
            summ1 = summ
        }
        
        let fr = (Double(round(1000*summ1)/1000))
        todayButton.setTitle(String(fr), for: .normal)
    }
    
    //валюта последней транзакции
    func lastPaymentCurrency() -> String {
        var d = ""
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Payment")
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.fetchLimit = 1
        do {
            let results = try! CoreDataManager.instance.managedObjectContext.fetch(fetchRequest)
            for result in results as! [Payment] {
                if let res = result.currency?.code {
                    d = res
                }
            }
        }
        return d
    }
    
    func dateString(date: NSDate) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        dateFormatter.string(from: date as Date)
        return "\(dateFormatter.string(from: date as Date))\n"
    }
    
    //добавить кнопки с валютами
    func buttonCurrency() {
        
        switch countOfCurrencyToday().count {
        case 1:
            calculate(cur: currencyFromCode(code: countOfCurrencyToday()[0]))
        case 2:
            if countOfCurrencyToday()[0] == lastPaymentCurrency() {
                drowCurrencyButton(x: 89, y: 46, code: countOfCurrencyToday()[0], activeted: true, tag: 201)
                drowCurrencyButton(x: 145, y: 46, code: countOfCurrencyToday()[1], activeted: false, tag: 202)
                calculate(cur: currencyFromCode(code: countOfCurrencyToday()[0]))
            } else if countOfCurrencyToday()[1] == lastPaymentCurrency() {
                drowCurrencyButton(x: 89, y: 46, code: countOfCurrencyToday()[1], activeted: true, tag: 201)
                drowCurrencyButton(x: 145, y: 46, code: countOfCurrencyToday()[0], activeted: false, tag: 202)
                calculate(cur: currencyFromCode(code: countOfCurrencyToday()[1]))
            } else {
                drowCurrencyButton(x: 89, y: 46, code: countOfCurrencyToday()[0], activeted: true, tag: 201)
                drowCurrencyButton(x: 145, y: 46, code: countOfCurrencyToday()[1], activeted: false, tag: 202)
                calculate(cur: currencyFromCode(code: countOfCurrencyToday()[0]))
            }
        case 3:
            if countOfCurrencyToday()[0] == lastPaymentCurrency() {
                drowCurrencyButton(x: 55, y: 46, code: countOfCurrencyToday()[0], activeted: true, tag: 201)
                drowCurrencyButton(x: 117, y: 46, code: countOfCurrencyToday()[1], activeted: false, tag: 202)
                drowCurrencyButton(x: 179, y: 46, code: countOfCurrencyToday()[2], activeted: false, tag: 203)
                calculate(cur: currencyFromCode(code: countOfCurrencyToday()[0]))
            } else if countOfCurrencyToday()[1] == lastPaymentCurrency() {
                drowCurrencyButton(x: 55, y: 46, code: countOfCurrencyToday()[1], activeted: true, tag: 201)
                drowCurrencyButton(x: 117, y: 46, code: countOfCurrencyToday()[0], activeted: false, tag: 202)
                drowCurrencyButton(x: 179, y: 46, code: countOfCurrencyToday()[2], activeted: false, tag: 203)
                calculate(cur: currencyFromCode(code: countOfCurrencyToday()[1]))
            } else if countOfCurrencyToday()[2] == lastPaymentCurrency() {
                drowCurrencyButton(x: 55, y: 46, code: countOfCurrencyToday()[2], activeted: true, tag: 201)
                drowCurrencyButton(x: 117, y: 46, code: countOfCurrencyToday()[1], activeted: false, tag: 202)
                drowCurrencyButton(x: 179, y: 46, code: countOfCurrencyToday()[0], activeted: false, tag: 203)
                calculate(cur: currencyFromCode(code: countOfCurrencyToday()[2]))
            } else {
                drowCurrencyButton(x: 55, y: 46, code: countOfCurrencyToday()[0], activeted: true, tag: 201)
                drowCurrencyButton(x: 117, y: 46, code: countOfCurrencyToday()[1], activeted: false, tag: 202)
                drowCurrencyButton(x: 179, y: 46, code: countOfCurrencyToday()[2], activeted: false, tag: 203)
                calculate(cur: currencyFromCode(code: countOfCurrencyToday()[0]))
            }
        default:
            print("error")
        }
    }
    
    func drowCurrencyButton(x: Int, y: Int, code: String, activeted: Bool, tag: Int) {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: x, y: y, width: 41, height: 41)
        button.layer.cornerRadius = 0.5 * button.bounds.size.width
        if activeted {
            button.backgroundColor = UIColor(white: 1, alpha: 0.3)
        } else {
            button.backgroundColor = UIColor.clear
        }
        button.setTitle(code, for: .normal)
        button.tag = tag
        button.titleLabel?.font = UIFont(name: "GothamPro-Medium", size: 12)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.textColor = UIColor(white: 1, alpha: 0.45)
        button.addTarget(self, action: #selector(ImageAction), for: .touchUpInside)
        self.todayButton.addSubview(button)
    }
    
    
    @IBAction func ImageAction(_ sender: UIButton) {
        let activeCurrencyArray = countOfCurrencyToday()
        let ar = [201, 202, 203]
        var tg = 0
        
        for i in activeCurrencyArray {
            if i == sender.currentTitle {
                calculate(cur: currencyFromCode(code: i))
                sender.backgroundColor = UIColor(white: 1, alpha: 0.3)
                tg = sender.tag
            }
        }
        
        for i in ar {
            if i != tg {
                let tempButton = self.view.viewWithTag(i) as? UIButton
                tempButton?.backgroundColor = UIColor.clear
            }
        }
    }
    
    @IBAction func ovalTodayAction(_ sender: UIButton) {
/*        var activeCurrencyArray = [(Currency, Bool)]()
        if arcu.isEmpty {
            activeCurrencyArray = ctfd.existLastPaymentCurrencyInArray()
        } else {
            activeCurrencyArray = arcu
        }
*/
        let testVC = Payment1CategoryTableViewController.storyboardInstance()
        testVC?.startDate = datFrom
        testVC?.endDate = datTo
        testVC?.dataStr = (dateString(date: datFrom), "TODAY")
        
/*        for i in activeCurrencyArray {
            if i.1 {
                testVC?.currency = i.0
            }
        }
*/
        self.present(testVC!, animated: false, completion: nil)
    }
}
