import undetected_chromedriver as uc
from robot.libraries.BuiltIn import BuiltIn
import time

class UcLibrary:
    ROBOT_LIBRARY_SCOPE = 'GLOBAL'

    def switch_to_browser(self, alias):
        selenium_lib = BuiltIn().get_library_instance('SeleniumLibrary')
        selenium_lib.switch_browser(alias)
        driver = selenium_lib.driver
        window_handle = driver.current_window_handle
        driver.switch_to.window(window_handle)
        driver.minimize_window()
        driver.maximize_window()
        BuiltIn().log(
            f"Switched to browser alias '{alias}' "
            f"(session={driver.session_id}, url={driver.current_url})"
        )

    # 1. เพิ่ม alias='undetected_chrome' เข้ามาในวงเล็บ (เป็นการตั้งค่า Default เผื่อลืมใส่)
    def open_undetected_browser(self, url, wait_time=10, alias='undetected_chrome'):
        options = uc.ChromeOptions()
        options.add_argument("--disable-popup-blocking")
        
        # driver = uc.Chrome(options=options, version_main=155)
        driver = uc.Chrome(options=options)
        driver.maximize_window()
        
        try:
            selenium_lib = BuiltIn().get_library_instance('SeleniumLibrary')
            # 2. เปลี่ยนตรงนี้ ให้ใช้ตัวแปร alias แทนการพิมพ์ชื่อตรงๆ
            selenium_lib.register_driver(driver, alias)
        except RuntimeError:
            raise RuntimeError("ไม่พบ SeleniumLibrary กรุณาเช็คว่ามีการ Import ในไฟล์ .robot แล้ว")
            
        if len(driver.window_handles) > 1:
            driver.switch_to.window(driver.window_handles[0])
            driver.close()
            driver.switch_to.window(driver.window_handles[-1])

        driver.set_page_load_timeout(30)
        driver.implicitly_wait(wait_time)
        driver.get(url)
        time.sleep(2)
        
        return driver