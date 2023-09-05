(import-macros {: Types
                : General
                : Type} :type-hint)
(local list (require :ai-assistant.list))
(local {: Profile
        : Context} (require :ai-assistant.types))

(fn session-manager [create-session]
  (let [sessions {}]
    (fn get-session [{: profile &as opts}]
      (let [session (. sessions profile)]
        (if (not session)
          (let [session (create-session opts)]
            (tset sessions profile session)
            session)
          session)))
    {: get-session}))

{: session-manager}
