(this["webpackJsonp@rclone/rclone-webui-react"]=this["webpackJsonp@rclone/rclone-webui-react"]||[]).push([[18],{276:function(e,t,r){"use strict";function n(e,t){(null==t||t>e.length)&&(t=e.length);for(var r=0,n=new Array(t);r<t;r++)n[r]=e[r];return n}function a(e,t){return function(e){if(Array.isArray(e))return e}(e)||function(e,t){if("undefined"!==typeof Symbol&&Symbol.iterator in Object(e)){var r=[],n=!0,a=!1,o=void 0;try{for(var s,l=e[Symbol.iterator]();!(n=(s=l.next()).done)&&(r.push(s.value),!t||r.length!==t);n=!0);}catch(i){a=!0,o=i}finally{try{n||null==l.return||l.return()}finally{if(a)throw o}}return r}}(e,t)||function(e,t){if(e){if("string"===typeof e)return n(e,t);var r=Object.prototype.toString.call(e).slice(8,-1);return"Object"===r&&e.constructor&&(r=e.constructor.name),"Map"===r||"Set"===r?Array.from(r):"Arguments"===r||/^(?:Ui|I)nt(?:8|16|32)(?:Clamped)?Array$/.test(r)?n(e,t):void 0}}(e,t)||function(){throw new TypeError("Invalid attempt to destructure non-iterable instance.\nIn order to be iterable, non-array objects must have a [Symbol.iterator]() method.")}()}r.d(t,"a",(function(){return a}))},293:function(e,t,r){"use strict";var n=r(7),a=r(10),o=r(274),s=r(16),l=r(0),i=r.n(l),c=r(4),u=r.n(c),d=r(24),p=r.n(d),b=r(27),m={active:u.a.bool,"aria-label":u.a.string,block:u.a.bool,color:u.a.string,disabled:u.a.bool,outline:u.a.bool,tag:b.q,innerRef:u.a.oneOfType([u.a.object,u.a.func,u.a.string]),onClick:u.a.func,size:u.a.string,children:u.a.node,className:u.a.string,cssModule:u.a.object,close:u.a.bool},f=function(e){function t(t){var r;return(r=e.call(this,t)||this).onClick=r.onClick.bind(Object(o.a)(r)),r}Object(s.a)(t,e);var r=t.prototype;return r.onClick=function(e){this.props.disabled?e.preventDefault():this.props.onClick&&this.props.onClick(e)},r.render=function(){var e=this.props,t=e.active,r=e["aria-label"],o=e.block,s=e.className,l=e.close,c=e.cssModule,u=e.color,d=e.outline,m=e.size,f=e.tag,h=e.innerRef,g=Object(a.a)(e,["active","aria-label","block","className","close","cssModule","color","outline","size","tag","innerRef"]);l&&"undefined"===typeof g.children&&(g.children=i.a.createElement("span",{"aria-hidden":!0},"\xd7"));var v="btn"+(d?"-outline":"")+"-"+u,y=Object(b.m)(p()(s,{close:l},l||"btn",l||v,!!m&&"btn-"+m,!!o&&"btn-block",{active:t,disabled:this.props.disabled}),c);g.href&&"button"===f&&(f="a");var C=l?"Close":null;return i.a.createElement(f,Object(n.a)({type:"button"===f&&g.onClick?"button":void 0},g,{className:y,ref:h,onClick:this.onClick,"aria-label":r||C}))},t}(i.a.Component);f.propTypes=m,f.defaultProps={color:"secondary",tag:"button"},t.a=f},327:function(e,t,r){"use strict";r.d(t,"b",(function(){return o})),r.d(t,"a",(function(){return s}));var n=r(2),a=r(284);const o=()=>e=>{Object(a.getAllProviders)().then(t=>e({type:n.y,payload:t.providers}))},s=()=>e=>{Object(a.getAllConfigDump)().then(t=>e({type:n.u,status:n.L,payload:t}),t=>e({type:n.u,status:n.J,payload:t}))}},374:function(e,t,r){"use strict";var n=r(7),a=r(10),o=r(0),s=r.n(o),l=r(4),i=r.n(l),c=r(24),u=r.n(c),d=r(27),p={className:i.a.string,cssModule:i.a.object,size:i.a.string,bordered:i.a.bool,borderless:i.a.bool,striped:i.a.bool,dark:i.a.bool,hover:i.a.bool,responsive:i.a.oneOfType([i.a.bool,i.a.string]),tag:d.q,responsiveTag:d.q,innerRef:i.a.oneOfType([i.a.func,i.a.string,i.a.object])},b=function(e){var t=e.className,r=e.cssModule,o=e.size,l=e.bordered,i=e.borderless,c=e.striped,p=e.dark,b=e.hover,m=e.responsive,f=e.tag,h=e.responsiveTag,g=e.innerRef,v=Object(a.a)(e,["className","cssModule","size","bordered","borderless","striped","dark","hover","responsive","tag","responsiveTag","innerRef"]),y=Object(d.m)(u()(t,"table",!!o&&"table-"+o,!!l&&"table-bordered",!!i&&"table-borderless",!!c&&"table-striped",!!p&&"table-dark",!!b&&"table-hover"),r),C=s.a.createElement(f,Object(n.a)({},v,{ref:g,className:y}));if(m){var k=Object(d.m)(!0===m?"table-responsive":"table-responsive-"+m,r);return s.a.createElement(h,{className:k},C)}return C};b.propTypes=p,b.defaultProps={tag:"table",responsiveTag:"div"},t.a=b},646:function(e,t,r){"use strict";r.r(t);var n=r(276),a=r(0),o=r.n(a),s=r(60),l=r(41),i=r(293),c=r(374),u=r(62),d=r(36),p=r(11),b=r(43);class m extends o.a.Component{constructor(e,t){super(e,t),this.onUpdateClicked=()=>{const e=this.state.remote.name;this.props.history.push("/newdrive/edit/"+e)};let r=this.props,n=r.remote,a=r.remoteName;n.name=a,this.state={remote:n},this.onDeleteClicked=this.onDeleteClicked.bind(this),this.onUpdateClicked=this.onUpdateClicked.bind(this)}onDeleteClicked(){const e=this.state.remote.name;let t=this.props.refreshHandle;window.confirm("Are you sure you wish to delete ".concat(e,"? You cannot restore it once it is deleted."))&&u.a.post(b.a.deleteConfig,{name:e}).then(e=>{t(),d.b.info("Config deleted")},e=>{d.b.error("Error deleting config")})}render(){const e=this.state.remote,t=e.name,r=e.type,n=this.props.sequenceNumber;return o.a.createElement("tr",{"data-test":"configRowComponent"},o.a.createElement("th",{scope:"row"},n),o.a.createElement("td",null,t),o.a.createElement("td",null,r),o.a.createElement("td",null,o.a.createElement(i.a,{className:"bg-info mr-2",onClick:this.onUpdateClicked},"Update"),o.a.createElement(i.a,{className:"bg-danger",onClick:this.onDeleteClicked},"Delete")))}}var f=Object(p.g)(m),h=r(84),g=r(327);function v({remotes:e,refreshHandle:t}){let r=[],a=1;for(var s=0,l=Object.entries(e);s<l.length;s++){const e=Object(n.a)(l[s],2),i=e[0],c=e[1];r.push(o.a.createElement(f,{sequenceNumber:a,key:i,remoteName:i,remote:c,refreshHandle:t})),a++}return r}class y extends o.a.PureComponent{componentDidMount(){this.props.getConfigDump()}render(){return o.a.createElement("div",{"data-test":"showConfigComponent"},o.a.createElement(s.a,null,o.a.createElement(l.a,{lg:8,className:"mb-4"},o.a.createElement(i.a,{color:"primary",className:"float-left",onClick:()=>this.props.history.push("/newdrive")},"Create a New Config")),o.a.createElement(l.a,{lg:4})),o.a.createElement(c.a,{responsive:!0,className:"table-striped"},o.a.createElement("thead",null,o.a.createElement("tr",null,o.a.createElement("th",null,"No."),o.a.createElement("th",null,"Name"),o.a.createElement("th",null,"Type"),o.a.createElement("th",null,"Actions"))),o.a.createElement("tbody",null,o.a.createElement(v,{remotes:this.props.remotes,refreshHandle:this.props.getConfigDump}))))}}t.default=Object(h.b)(e=>({remotes:e.config.configDump,hasError:e.config.hasError,error:e.config.error}),{getConfigDump:g.a})(y)}}]);
//# sourceMappingURL=18.5ee5b6a8.chunk.js.map