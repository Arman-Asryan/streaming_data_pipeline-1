from datetime import datetime, timedelta

def find_start_date(current_date):
    weekday = current_date.weekday()
    if weekday == 0:  # Monday
        start_date = current_date - timedelta(days=3)
    elif weekday == 6:  # Sunday
        start_date = current_date - timedelta(days=2)
    else:
        start_date = current_date - timedelta(days=1)
    return start_date