
###
другой пример `TodoMVC`
(видимо используется чистый инстанс puremvc.Facade тк нет кода ApplicationFacade унаследованного от puremvc.Facade)
```coffee
class TodoMVC.AppConstants
  # The multiton key for this app's single core
  @CORE_NAME:                'TodoMVC'

  # Notifications
  @STARTUP:                  'startup',
  @ADD_TODO:                 'add_todo',
  @DELETE_TODO:              'delete_todo',
  @UPDATE_TODO:              'update_todo',
  @TOGGLE_TODO_STATUS:       'toggle_todo_status',
  @REMOVE_TODOS_COMPLETED:   'remove_todos_completed',
  @FILTER_TODOS:             'filter_todos',
  @TODOS_FILTERED:           'todos_filtered',

  # Filter routes
  @FILTER_ALL:                'all',
  @FILTER_ACTIVE:             'active',
  @FILTER_COMPLETED:          'completed'

class TodoMVC.Application
  STARTUP: 'startup'
  facade: puremvc.Facade.getInstance TodoMVC.AppConstants.CORE_NAME
  constructor: ->
    @facade.registerCommand TodoMVC.AppConstants.STARTUP, TodoMVC.controller.command.StartupCommand
    @facade.sendNotification TodoMVC.AppConstants.STARTUP
```
in index.html
```
<script>
        document.addEventListener('DOMContentLoaded', function()
        {
            var app = new TodoMVC.Application();
        });
</script>
```
###


###
другой пример `LockableDoor`
```coffee
class ApplicationFacade extends LeanRC::Facade
  # The multiton key for this app's single core
  @CORE_NAME:                'TodoMVC'

  # Notifications
  @STARTUP:                  'startup',
  @ADD_TODO:                 'add_todo',
  @DELETE_TODO:              'delete_todo',
  @UPDATE_TODO:              'update_todo',
  @TOGGLE_TODO_STATUS:       'toggle_todo_status',
  @REMOVE_TODOS_COMPLETED:   'remove_todos_completed',
  @FILTER_TODOS:             'filter_todos',
  @TODOS_FILTERED:           'todos_filtered',

  # Filter routes
  @FILTER_ALL:                'all',
  @FILTER_ACTIVE:             'active',
  @FILTER_COMPLETED:          'completed'

  @getInstance: (multitonKey)->
    instanceMap = LeanRC::Facade.instanceMap
    instance = instanceMap[multitonKey]
    if instance
      return instance
    instanceMap[multitonKey] = new ApplicationFacade multitonKey

  initializeController: ->
    super
    @registerCommand ApplicationFacade.STARTUP, controller.StartupCommand
    @registerCommand ApplicationFacade.EXITING_CLOSED_STATE, controller.ExitingClosedStateCommand
    @registerCommand ApplicationFacade.ENTERING_OPENED_STATE, controller.EnteringOpenedStateCommand
    @registerCommand ApplicationFacade.CHANGED_CLOSED_STATE, controller.ChangedClosedStateCommand
    @registerCommand ApplicationFacade.ENTER, controller.EnterCommand
    @registerCommand ApplicationFacade.EXIT, controller.ExitCommand

  startup: (app)->
    @sendNotification ApplicationFacade.STARTUP, app

  constructor: (multitonKey)->
    super

class LockableDoor
  @NAME: "LockableDoor"

  @STATE_CLOSED: "LockableDoor/states/closed",
  @STATE_OPENED: "LockableDoor/states/opened",
  @STATE_LOCKED: "LockableDoor/states/locked",

  @ACTION_OPEN: "LockableDoor/actions/open",
  @ACTION_CLOSE: "LockableDoor/actions/close",
  @ACTION_LOCK: "LockableDoor/actions/lock",
  @ACTION_UNLOCK: "LockableDoor/actions/unlock"

  # ... some instance properties and methods

  constructor: ->
    ApplicationFacade.getInstance(LockableDoor.NAME).startup(this)
```
in index.html
```
<script>
        document.addEventListener('DOMContentLoaded', function()
        {
            var app = new LockableDoor();
        });
</script>
```
###


###
другой пример `ReverseTextDemo`
```coffee
class AppConstants
  @STARTUP: 'startup'
  @PROCESS_TEXT: 'processText'
  @PALINDROME_DETECTED: 'palindromeDetected'

class ApplicationFacade extends LeanRC::Facade
  @NAME:                'ReverseTextDemo'

  @getInstance: (multitonKey)->
    instanceMap = LeanRC::Facade.instanceMap
    instance = instanceMap[multitonKey]
    if instance
      return instance
    instanceMap[multitonKey] = new ApplicationFacade multitonKey

  startup: (app)->
    unless @initialized
      @initialized = yes
      @registerCommand AppConstants.STARTUP, demo.controller.command.StartupCommand
      @sendNotification AppConstants.STARTUP

```
in index.html
```
<script>
        document.addEventListener('DOMContentLoaded', function()
        {
            ApplicationFacade.getInstance(ApplicationFacade.NAME).startup();
        });
</script>
```
###


###
другой пример `EmployeeAdminDemo`
```coffee
class ApplicationFacade extends LeanRC::Facade
  STARTUP: "Startup"
  NEW_USER: "newUser"
  DELETE_USER: "deleteUser"
  CANCEL_SELECTED: "cancelSelected"
  USER_SELECTED: "userSelected"
  USER_ADDED: "userAdded"
  USER_UPDATED:  "userUpdated"

  @getInstance: (multitonKey)->
    unless LeanRC::Facade.hasCore multitonKey # в LeanRC::Facade нет такого метода
      new ApplicationFacade multitonKey
    LeanRC::Facade.getInstance multitonKey

  initializeController: ->
    super
    @registerCommand ApplicationFacade.STARTUP, StartupCommand

  startup: (viewComponent)->
    @sendNotification AppConstants.STARTUP, viewComponent

```
in index.html
```
<script>
        document.addEventListener('DOMContentLoaded', function()
        {
            ApplicationFacade.getInstance("EmployeeAdminDemo").startup();
        });
</script>
```
###
RC      = require 'RC'
LeanRC  = require 'LeanRC'


class Groups extends RC::Module

require('./Constants') Groups

require('./controller/command/StartupCommand') Groups
require('./controller/command/PrepareControllerCommand') Groups
require('./controller/command/PrepareViewCommand') Groups
require('./controller/command/PrepareModelCommand') Groups
# require('./controller/command/AnimateRobotCommand') Groups

# require('./view/component/ConsoleComponent') Groups
# require('./view/mediator/ConsoleComponentMediator') Groups
require('./view/mediator/ApplicationMediator') Groups
#
# require('./model/proxy/RobotDataProxy') Groups

require('./ApplicationFacade') Groups

require('./Application') Groups


module.exports = Groups
