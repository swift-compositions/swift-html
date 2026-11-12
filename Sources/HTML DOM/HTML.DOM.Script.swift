#if DOM
    extension HTML.DOM {

        public enum Script {}
    }

    extension HTML.DOM.Script {

        public static let source: String = #"""
            const decoder = new TextDecoder();
            const encoder = new TextEncoder();

            export async function start(url) {
              const nodes = [null];
              let memory;
              let exports;
              let current = null;
              let scheduled = false;
              let sheet = null;

              const html_dom = {
                flush(pointer, count) {
                  const bytes = new Uint8Array(memory.buffer, pointer, count);
                  const view = new DataView(memory.buffer, pointer, count);
                  let at = 0;
                  const int = () => { const value = view.getInt32(at, true); at += 4; return value; };
                  const string = () => { const length = int(); const value = decoder.decode(bytes.subarray(at, at + length)); at += length; return value; };
                  while (at < count) {
                    switch (bytes[at++]) {
                      case 1: { const id = int(); nodes[id] = document.createElement(string()); break; }
                      case 2: { const id = int(); nodes[id] = document.createTextNode(string()); break; }
                      case 3: { const id = int(); nodes[id] = document.querySelector(string()); break; }
                      case 4: { const parent = nodes[int()]; const child = nodes[int()]; const before = int(); parent.insertBefore(child, before > 0 ? nodes[before] : null); break; }
                      case 5: { const id = int(); nodes[id].remove(); nodes[id] = null; break; }
                      case 6: { nodes[int()] = null; break; }
                      case 7: { const node = nodes[int()]; const name = string(); node.setAttribute(name, string()); break; }
                      case 8: { const node = nodes[int()]; node.removeAttribute(string()); break; }
                      case 9: { const node = nodes[int()]; const value = string(); if (node.value !== value) node.value = value; break; }
                      case 10: { const node = nodes[int()]; node.checked = bytes[at++] !== 0; break; }
                      case 11: { const node = nodes[int()]; node.data = string(); break; }
                      case 12: {
                        const node = nodes[int()]; const event = string(); const listener = int();
                        const handler = (e) => {
                          if (event === "submit") e.preventDefault();
                          current = e;
                          try { exports.html_dom_dispatch(listener); } finally { current = null; }
                        };
                        (node.__listeners ??= new Map()).set(listener, handler);
                        node.addEventListener(event, handler);
                        break;
                      }
                      case 13: {
                        const node = nodes[int()]; const event = string(); const listener = int();
                        const handler = node.__listeners?.get(listener);
                        if (handler) { node.removeEventListener(event, handler); node.__listeners.delete(listener); }
                        break;
                      }
                      case 14: { nodes[int()].replaceChildren(); break; }
                      case 15: {
                        if (!sheet) { const style = document.createElement("style"); document.head.append(style); sheet = style.sheet; }
                        sheet.insertRule(string(), sheet.cssRules.length);
                        break;
                      }
                      default: throw new Error("html_dom: unknown operation");
                    }
                  }
                },
                schedule() {
                  if (scheduled) return;
                  scheduled = true;
                  queueMicrotask(() => { scheduled = false; exports.html_dom_tick(); });
                },
                value(pointer, capacity) {
                  const target = current?.target;
                  const encoded = encoder.encode(target && "value" in target ? String(target.value) : "");
                  if (encoded.length <= capacity && encoded.length > 0) new Uint8Array(memory.buffer, pointer, encoded.length).set(encoded);
                  return encoded.length;
                },
                checked() {
                  return current?.target?.checked ? 1 : 0;
                },
              };

              const wasi = {
                fd_write(fd, iovs, length, written) {
                  const view = new DataView(memory.buffer);
                  let total = 0; let text = "";
                  for (let i = 0; i < length; i++) {
                    const pointer = view.getUint32(iovs + i * 8, true);
                    const size = view.getUint32(iovs + i * 8 + 4, true);
                    text += decoder.decode(new Uint8Array(memory.buffer, pointer, size));
                    total += size;
                  }
                  (fd === 2 ? console.error : console.log)(text);
                  view.setUint32(written, total, true);
                  return 0;
                },
                args_sizes_get(count, size) { const view = new DataView(memory.buffer); view.setUint32(count, 0, true); view.setUint32(size, 0, true); return 0; },
                args_get() { return 0; },
                random_get(pointer, length) { crypto.getRandomValues(new Uint8Array(memory.buffer, pointer, length)); return 0; },
                clock_time_get(id, precision, result) { new DataView(memory.buffer).setBigUint64(result, BigInt(Math.round(performance.now() * 1e6)), true); return 0; },
                proc_exit(code) { throw new Error("exit " + code); },
              };

              const module = await WebAssembly.compileStreaming(fetch(url));
              const imports = { html_dom };
              for (const { module: from, name, kind } of WebAssembly.Module.imports(module)) {
                if (kind !== "function" || from === "html_dom") continue;
                imports[from] ??= {};
                imports[from][name] = wasi[name] ?? (() => 52);
              }
              const instance = await WebAssembly.instantiate(module, imports);
              exports = instance.exports;
              memory = exports.memory;
              if (exports._start) exports._start(); else exports._initialize?.();
              return exports;
            }
            """#
    }
#endif
