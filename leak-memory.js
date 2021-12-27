const leak = [];

setInterval(() => {
    leak.push(new Array(1e6).fill("some string"));
}, 1000);
