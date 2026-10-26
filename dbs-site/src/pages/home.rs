use crate::components::counter_btn::Button;
use crate::components::types_box::Box;
use leptos::prelude::*;

use console_error_panic_hook::set_once as set_panic_hook;
use wasm_bindgen::prelude::*;


#[wasm_bindgen(module = "/static/engine.js")]
extern "C" {
    fn query(q: &str) -> String;
}

#[wasm_bindgen]
extern "C" {
    #[wasm_bindgen(js_namespace = console)]
    fn log(s: &str);
}

// literally just a slightly modified version of the leptos tutorial

#[component]
pub fn Home() -> impl IntoView {
    let villagers = RwSignal::new((4).to_string());
    let outcasts = RwSignal::new((0).to_string());
    let minions = RwSignal::new((1).to_string());
    let demons = RwSignal::new((0).to_string());

    log(&query("sums(Sums), clues(Clues),db_solver(Sums,Clues,AlignmentList)."));

    view! {
        <ErrorBoundary fallback=|errors| {
            view! {
                <h1>"Uh oh! Something went wrong!"</h1>

                <p>"Errors: "</p>
                // Render a list of errors as strings - good for development purposes
                <ul>
                    {move || {
                        errors
                            .get()
                            .into_iter()
                            .map(|(_, e)| view! { <li>{e.to_string()}</li> })
                            .collect_view()
                    }}

                </ul>
            }
        }>

            <div class="vcontainer">

                <h1>"Demon Bluff Solver"</h1>

                <h2 style="margin: 0pt;border: 0pt; padding: 0pt"> "Village Population" </h2>
                <div class="hcontainer">
                    <Box typename="Villagers" population=villagers/>
                    <Box typename="Outcasts" population=outcasts/>
                    <Box typename="Minions" population=minions/>
                    <Box typename="Demons" population=demons/>
                </div>


            </div>
        </ErrorBoundary>
    }
}
