# Pin npm packages by running ./bin/importmap

pin "application"
pin "notifications" # @0.2.0
pin "@rails/actioncable", to: "actioncable.esm.js"
pin_all_from "app/javascript/channels", under: "channels"
