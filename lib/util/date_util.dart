class DateUtil {

  late DateTime _nextMessageDateTime;
  
  set nextMessageDateTime(DateTime nextMessageDate) =>_nextMessageDateTime = nextMessageDate;

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

  static Map<int, String> fullDays = {
    1: "Monday",
    2: "Tuesday",
    3: "Wednesday",
    4: "Thursday",
    5: "Friday",
    6: "Saturday",
    7: "Sunday"
  };

  static Map<int, String> fullMonths = {
    1: "January",
    2: "February",
    3: "March",
    4: "April",
    5: "May",
    6: "June",
    7: "July",
    8: "August",
    9: "September",
    10: "October",
    11: "November",
    12: "December"
  };

  /// Formats given [date] into a readable and good-looking format.
  static String getFormatedTime(DateTime date) {
    int hour = date.hour;
    int minute = date.minute;

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

  /// Different versions based on time difference between current time and the given one.
  /// Returns dates with shortened names.
  static String getShortDateFormatFromNow(DateTime date) {
    DateTime now = DateTime.now();
    Duration difference = now.difference(date);

    // Check if the difference is more than or equal to a year
    bool moreThanAYear = (now.year > date.year) ||
      (now.year == date.year && difference.inDays >= 365) ||
      (isLeapYear(date.year) && difference.inDays >= 366);

    if (moreThanAYear) {
      // String for dates more than a year ago
      return "${date.day}.${date.month}.${date.year}";
    } else if (difference.inDays >= 7) {
      // String for dates more than a week ago
      return "${months[date.month]} ${date.day}";
    } else if (difference.inDays >= 1) {
      // String for dates more than a day ago
      return days[date.weekday].toString();
    } else {
      // String for dates within a day
      return getFormatedTime(date);
    }
  }

  bool isMessageDateDifferenceMoreThanOrEqualDay(DateTime lastMessageDate) => lastMessageDate.difference(_nextMessageDateTime).inDays >= 1;

  static bool isTodayDate(DateTime date) {
    DateTime dateTimeNow = DateTime.now();

    return (
      dateTimeNow.day == date.day
        && dateTimeNow.month == date.month
        && dateTimeNow.year == date.year
    );
  }

  /// Different versions based on time difference between current time and the given one.
  /// Returns full-named dates.
  static String getLongDateFormatFromNow(DateTime date) {
    DateTime now = DateTime.now();
    Duration difference = now.difference(date);

    // Check if the difference is more than or equal to a year
    bool moreThanAYear = (now.year > date.year) ||
      (now.year == date.year && difference.inDays >= 365) ||
      (isLeapYear(date.year) && difference.inDays >= 366);

    if (moreThanAYear) {
      // String for dates more than a year ago
      return "${fullMonths[date.month]} ${date.day}, ${date.year}";
    } else if (difference.inDays >= 7) {
      // String for dates more than a week ago
      return "${fullMonths[date.month]} ${date.day}";
    } else if (difference.inDays >= 1) {
      // String for dates more than a day ago
      return fullDays[date.weekday].toString();
    } else {
      // String for dates within a day
      return getFormatedTime(date);
    }
  }
}
