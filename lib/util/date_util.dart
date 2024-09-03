class DateUtil {

  static Map<int, String> days = {
    1: "Mon",
    2: "Tues",
    3: "Wed",
    4: "Thu",
    5: "Fri",
    6: "Sat",
    7: "Sun"
  };

  static Map<int, String> months = {
    1: "Jan",
    2: "Feb",
    3: "Mar",
    4: "Apr",
    5: "May",
    6: "Jun",
    7: "Jul",
    8: "Aug",
    9: "Sep",
    10: "Oct",
    11: "Nov",
    12: "Dec"
  };


  /// Formats given [itemInitDate] into a readable and good-looking format.
  static String getFormatedInitTime(DateTime itemInitDate) {
    int hour = itemInitDate.hour;
    int minute = itemInitDate.minute;

    String period = hour >= 12 ? "PM" : "AM";

    // Hour to 12-hour format Convertion
    hour = hour % 12;

    if (hour == 0) {
      hour = 12;
    }

    String minuteStr = minute < 10 ? "0$minute" : "$minute";

    return "$hour:$minuteStr $period";
  }
  
  static bool isLeapYear(int year) {
    if (year % 4 != 0) return false;
    if (year % 100 != 0) return true;
    if (year % 400 != 0) return false;
    return true;
  }

  /// Different versions based on time difference between current time and init time for the item.
  static String getCurrentDate(DateTime itemInitDate) {
    DateTime now = DateTime.now();
    Duration difference = now.difference(itemInitDate);

    // Check if the difference is more than or equal to a year
    bool moreThanAYear = (now.year > itemInitDate.year) ||
      (now.year == itemInitDate.year && difference.inDays >= 365) ||
      (isLeapYear(itemInitDate.year) && difference.inDays >= 366);

    if (moreThanAYear) {
      // String for dates more than a year ago
      return "${itemInitDate.day} ${months[itemInitDate.month]} ${itemInitDate.year}";
    } else if (difference.inDays >= 7) {
      // String for dates more than a week ago
      return "${itemInitDate.day} ${months[itemInitDate.month]}";
    } else if (difference.inDays >= 1) {
      // String for dates more than a day ago
      return days[itemInitDate.weekday].toString();
    } else {
      // String for dates within a day
      return getFormatedInitTime(itemInitDate);
    }
  }
}
