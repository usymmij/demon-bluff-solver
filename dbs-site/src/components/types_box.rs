use leptos::prelude::*;

/// A parameterized incrementing button
#[component]
pub fn Box(
    #[prop(into)]
    typename: String,
    population: RwSignal<std::string::String>
    ) -> impl IntoView {

    view! {
        <h3>{typename}
            <input type="number" value="1" min="0" step="1"
                // adding :target gives us typed access to the element
                // that is the target of the event that fires
                //on:input:target=move |ev| {
                //    // .value() returns the current value of an HTML input element
                //    set_name.set(ev.target().value());
                //}
    
                // the `prop:` syntax lets you update a DOM property,
                // rather than an attribute.
                bind:value=population
            />
        </h3>
    }
}
