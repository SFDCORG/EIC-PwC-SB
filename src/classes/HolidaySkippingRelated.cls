/**************************************************************************************************
 * Name: HolidaySkippingRelated
 * Object: ***
 * Purpose: ***
 * Author: Vicia Wang (vicia.hh.wang@cn.pwc.com)
 * Create Date: 2016-05-10
 * Modified History:
 * 2016-05-10    Allen    Format the code
***************************************************************************************************/
public class HolidaySkippingRelated {

   public Set<Date> holidays = new Set<Date> ();

   public HolidaySkippingRelated() {

   	   for (Holiday haliday : [SELECT ActivityDate
                               FROM Holiday 
                               WHERE ActivityDate >= :System.Today()]) {
          holidays.add(haliday.ActivityDate);
   	   }
   }

   public Date jumpHoliday (Date duedate) {
        
        While (holidays.contains(duedate)) {
            duedate= duedate.addDays(1);
        }

        return duedate;
   }
}