# vRouter IP Interface

Manage vRouter IP Interfaces. 

| Option      | Valid Values                                                  | Default      |
|-------------|---------------------------------------------------------------|:------------:|
|ensure       |present or absent                                              |**REQUIRED**  |
|vrouter      |local or fabric                                                |**REQUIRED**  |
|ip           |string, must be letters, numbers, \_, ., :, or -               | `''`         |
|mask         |comma seperated list, no whitespace. Must be between 2 and 4092| `'none'`     |
|require      |                                                             | |