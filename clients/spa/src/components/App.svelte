<script>
import Signup from "./Signup.svelte";

let activePage = 0;
const pages = [
	"Home",
	"Signup",
];

function updatePage(newPage) {
	console.log(`new active page:`, newPage);
	activePage = newPage;
}
</script>

<div class="flexcol fill_space">
<div class="flexrow">
{#each pages as page, index}
<button on:click={() => updatePage(index)}>{page}</button>
{/each}
</div>
{#if activePage === 0}
home
{:else if activePage === 1}
<Signup/>
{:else}
default
{/if}
</div>

<style>
.fill_width {
	width: 100%;
}

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
