document.addEventListener("DOMContentLoaded", () =>{
    const lnbItems = document.querySelectorAll("#lnb .title");
    const lnbSubItems = document.querySelectorAll("#lnb .subbox");
    const page = document.querySelector(".covihelp_content_right");

    lnbShowHide(lnbItems,lnbSubItems);
    lnbSubAutoActive(page, lnbItems);
});
window.addEventListener('load', (event) => {
    new SimpleBar(document.querySelector('.simplebar'), {
        autoHide: false
    });
    
    // 23.08.31 : covision modify(자체 수정) : version.
    document.getElementById("coviEditorVer").textContent = location.search.replace("?ver=", "");
});

 
// lnb 열고 닫기
const lnbShowHide = (lnbItems, lnbSubItems) => {
    lnbItems.forEach( (selectedItem) => {
        // lnb 클릭시 이벤트 등록
        selectedItem.addEventListener("click", (event) => {
            let item = event.target; 
            let sub = item.nextElementSibling; 
            
            if( sub.classList.contains('active') ) { 
                // 이미 열려 있는 항목이면 닫기
                item.classList.remove('active');
                sub.classList.remove('active');
                sub.style.display = 'none';
            }else{
                // 다른 영역을 클릭하면 열기
                lnbSubItems.forEach((lnbSubItem) => { 
                    lnbSubItem.classList.remove ('active');
                    lnbSubItem.style.display = 'none';
                })
                lnbItems.forEach((lnbItem) => { 
                    lnbItem.classList.remove('active');
                })

                item.classList.add('active');
                sub.classList.add('active');
                sub.style.display = 'block';

            }
        })
    })
}

// lnb sub auto active
const lnbSubAutoActive = (page, lnbItems) => {
    if (!page.querySelector('.title01')) return false;
    const pageName = page.querySelector('.title01').textContent;
    const pageSectionItems = page.querySelectorAll(".title02"); 
    const pageSectioinMargin = 10;
    let currentLnb; 
    let titleOffset = [];

    // 현재 보고 있는 페이지의 lnb 확인
    lnbItems.forEach( (lnbItem) => {
        if (lnbItem.textContent == pageName){
            currentLnb = lnbItem.nextElementSibling.querySelectorAll('li');
            return false; 
        }
    })
    // 제목의 offsetTop값 배열에 저장
    pageSectionItems.forEach( (titleItem) => {
        titleOffset.push(parseInt(titleItem.offsetTop) - pageSectioinMargin);
    })
    
    // 마우스 스크롤시 이벤트 등록
    page.addEventListener("scroll", () => {
        const currentTop = parseInt(page.scrollTop); 
        const innerHeight = window.innerHeight;
        const scrollHeight = page.scrollHeight + 60;

        let nearIndex = findNear ( titleOffset, currentTop);
        let currentItem = currentLnb[nearIndex]; 
        
        // 새 영역 이동 감지 및 lnb에서 해당 항목 활성화
        if(!currentItem.classList.contains('active')){
            currentLnb.forEach( (lnbItem) => {
                lnbItem.classList.remove('active');
            })
            currentItem.classList.add('active');
        }
        // 페이지 끝에 도달하면 무조건 lnb의 마지막 항목 활성화
        if (currentTop + innerHeight == scrollHeight  ) {
            currentLnb.forEach( (lnbItem) => {
                lnbItem.classList.remove('active');
            })
            currentLnb[currentLnb.length - 1].classList.add('active')
        }

    });
    page.addEventListener("resize", () => {
    
    })

}

// 근사값 검색 스크립트
const findNear = (data, target) => {
    let abs, near, nearIndex; 
    let min = [...data].pop();
    for(var i = 0; i < data.length; i++) {
        abs = ( (data[i] - target) < 0) ? -(data[i] - target) : (data[i] - target);
        if(abs < min) {
            min = abs; 
            near = data[i]; 
            nearIndex = i;
        }
    }
    return nearIndex; 
}

