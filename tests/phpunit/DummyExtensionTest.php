<?php

use DummyExtension\DummyExtension;

/**
 * Class DummyExtensionTest
 */
class DummyExtensionTest extends MediaWikiLangTestCase {

	public function setUp(): void {
		$this->setMwGlobals(
			[
				'wgDummyExtensionTestSetting' => false
			]
		);
	}

	/**
	 * @throws MWException
	 * @covers \DummyExtension\DummyExtension::testMe
	 */
	public function testDummyTestMe() {
		$dummy = new DummyExtension();
		$result = $dummy->testMe( 5, 10 );
		$this->assertTrue( $result === 15 );
	}

}
