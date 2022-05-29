<script>
import Signup from "./Signup.svelte";
</script>

<div class="flexcol main_container">
<Signup/>
</div>

<style>
div.main_container {
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
