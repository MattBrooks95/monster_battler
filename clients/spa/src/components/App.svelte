<script>
import Home from "./Home.svelte";
import Signup from "./Signup.svelte";
import Admin from "./Admin.svelte";
import Monsters from "./Monsters.svelte";
import Types from "./Types.svelte";

const pages = [
	["Home", Home],
	["Signup", Signup],
	["Accounts", null],
	["Admin", Admin],
	["Monsters", Monsters],
	["Types", Types]
];

let selectedComponent = pages[0][1];

function updateSelectedComponent(newPageIndex) {
	if (pages.length <= newPageIndex) {
		throw new Error(`component picker index:${index} went out of bounds`);
	}
	selectedComponent = pages[newPageIndex][1];
	console.log(`new active page:`, newPageIndex);
}
</script>

<div class="flexcol fill_space">
<div class="flexrow">
{#each pages as page, index}
<button on:click={() => updateSelectedComponent(index)}>{page[0]}</button>
{/each}
</div>
<svelte:component this={selectedComponent}/>
</div>

<style>
/*.fill_width {
	width: 100%;
}*/

.fill_space {
	width: 100%;
	height: 100%;
}

.flexcol {
	display: flex;
	flex-direction: column;
	align-items: center;
	justify-content: flex-start;
}
</style>
