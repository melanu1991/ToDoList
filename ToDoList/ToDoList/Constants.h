#ifndef Constants_h
#define Constants_h

static NSString * const VAKTaskWasChangedOrAddOrDelete = @"VAKTaskWasChangedOrAddOrDelete";
static NSString *const VAKTaskWasChanged = @"VAKTaskWasChanged";
static NSString * const VAKTaskWasComplited = @"TaskWasComplited";
static NSString * const VAKAddTaskTitle = @"Add Item";
static NSString * const VAKEditTaskTitle = @"Edit task";
static NSString * const VAKInboxCell = @"inboxCell";
static NSString * const VAKAddController = @"VAKAddTaskController";
static NSString * const VAKDetailSegue = @"detailSegue";
static NSString * const VAKKeySort = @"taskName";
static NSString * const VAKDateTitle = @"Choose date";
static NSString * const VAKDateController = @"VAKSelectDateController";
static NSString * const VAKSaveTitle = @"Save";
static NSUInteger const VAKIndexInboxView = 0;
static NSUInteger const VAKIndexToDoListView = 1;
static NSUInteger const VAKIndexSearchView = 2;
static NSUInteger const VAKIndexTodayView = 3;
static NSString * const VAKSearchCell = @"searchCell";
static NSString * const VAKSwitchingBetweenTabs = @"VAKSwitchingBetweenTabs";
static NSString * const VAKCustumCellIdentifier = @"custumCell";
static NSString * const VAKTitleForHeaderCompleted = @"Completed";
static NSString * const VAKEditButton = @"Edit";
static NSString * const VAKDoneButton = @"Done";
static NSString * const VAKCancelButton = @"Cancel";
static NSString * const VAKBackButton = @"Back";
static NSString * const VAKAddButton = @"+";
static NSString * const VAKDelete = @"Delete";
static NSString * const VAKOkButton = @"OK";
static NSString * const VAKWarningDeleteMessage = @"Are you sure you want remove this item?";
static NSString * const VAKDeleteTaskTitle = @"Delete task";
static NSString * const VAKAddNewTask = @"VAKAddNewTask";
static NSString * const VAKDeleteTask = @"VAKDeleteTask";
static NSString * const VAKSelectedDate = @"VAKSelectedDate";
static NSString * const VAKDeleteTaskToDoList = @"VAKDeleteTaskToDoList";

static NSString * const VAKSelectPriority = @"Select Priority";
static NSString * const VAKNone = @"None";
static NSString * const VAKLow = @"Low";
static NSString * const VAKMedium = @"Medium";
static NSString * const VAKHigh = @"High";

static NSString * const VAKReturnKey = @"\n";

static NSString * const VAKTaskNameCellIdentifier = @"VAKTaskNameCell";
static NSString * const VAKRemindCellIdentifier = @"VAKRemindCell";
static NSString * const VAKDateCellIdentifier = @"VAKDateCell";
static NSString * const VAKNotesCellIdentifier = @"VAKNotesCell";
static NSString * const VAKCustumCellNib = @"VAKCustumCell";
static NSString * const VAKPriorityCellIdentifier = @"VAKPriorityCell";

static NSString * const VAKTaskTitle = @"TASK";
static NSString * const VAKRemindTitle = @"REMIND";
static NSString * const VAKPriorityTitle = @"PRIORITY";
static NSString * const VAKNotesTitle = @"NOTES";

static NSString * const VAKAddProject = @"addProject";
static NSString * const VAKInbox = @"Inbox";
static NSString * const VAKToday =  @"Today";
static NSString * const VAKStoriboardIdentifierDetailTask = @"detailView";

static NSString * const VAKDateFormatWithHourAndMinute = @"EEEE, dd MMMM yyyy г., H:m";
static NSString * const VAKDateFormatWithoutHourAndMinute = @"dd.MM.YYYY";

static NSString * const VAKStoriboardIdentifierTodayViewController = @"VAKStoriboardIdentifierTodayViewController";
static NSString * const VAKTaskOfSelectedGroup = @"Tasks Of Selected Group";
static NSString * const VAKAddTaskForGroup = @"VAKAddTaskForGroup";

#endif
