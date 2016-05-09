public class HolidaySkippingRelated {
   
   public Set<Date> holidays = new Set<Date>();



   public HolidaySkippingRelated() {

   	   for(Holiday haliday : [select ActivityDate from Holiday where ActivityDate>=: system.today()])
   	   {
          holidays.add(haliday.ActivityDate);
   	   }
   }

   public Date jumpHoliday(Date duedate)
   {
        
        While(holidays.contains(duedate))
        {
        	duedate=duedate.addDays(1);
        }

        return duedate;
   }

}