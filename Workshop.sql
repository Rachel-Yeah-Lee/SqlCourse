--Workshop2
/*1.列出每個借閱人每年借書數量，並依借閱人編號和年度做排序
Table：BOOK_LEND_RECORD、MEMBER_M */
USE [GSSWEB]
GO

SELECT	KEEPER_ID AS KeeperId,mm.USER_CNAME AS CName, mm.USER_ENAME AS EName,YEAR(LR.LEND_DATE) AS BorrowYear,COUNT(KEEPER_ID) AS BorrowCnt
FROM	BOOK_LEND_RECORD AS blr
		JOIN MEMBER_M AS mm ON KEEPER_ID = [USER_ID]
GROUP BY KEEPER_ID,mm.USER_CNAME,mm.USER_ENAME,YEAR(LEND_DATE)
ORDER BY KeeperId,YEAR(LR.LEND_DATE);

/*2.列出最受歡迎的書前五名(借閱數量最多前五名)
Table：BOOK_LEND_RECORD */
SELECT TOP(5)blr.BOOK_ID AS BookId,bd.BOOK_NAME AS BookName,COUNT(bd.BOOK_ID) AS QTY 
FROM BOOK_LEND_RECORD blr
	 JOIN BOOK_DATA bd ON blr.BOOK_ID = bd.BOOK_ID
GROUP BY blr.BOOK_ID,bd.BOOK_NAME
ORDER BY QTY DESC;
/*3.以一季列出2019年每一季書籍借閱書量
Table：BOOK_LEND_RECORD*/
SELECT  [Quarter],COUNT([Quarter]) AS Cnt
FROM	(SELECT 
			CASE
				WHEN DATEPART(QUARTER,LEND_DATE)= 1 THEN '2019-01~2019-03'
				WHEN DATEPART(QUARTER,LEND_DATE)= 2 THEN '2019-04~2019-06'
				WHEN DATEPART(QUARTER,LEND_DATE)= 3 THEN '2019-07~2019-09'
				WHEN DATEPART(QUARTER,LEND_DATE)= 4 THEN '2019-10~2019-12'
			END AS [Quarter]
		 FROM BOOK_LEND_RECORD 
		 WHERE YEAR(LEND_DATE)=2019
		 )blr
GROUP BY [Quarter]
ORDER BY [Quarter]


/*4.撈出每個分類借閱數量前三名書本及數量
Table：BOOK_LEND_RECORD、BOOK_CLASS*/
SELECT Seq 
	  ,BookClassName AS BookClass
	  ,BookId
	  ,BookName
	  ,Cnt
FROM 
	(SELECT ROW_NUMBER() OVER(PARTITION BY bd.BOOK_CLASS_ID ORDER BY COUNT(bd.BOOK_ID)DESC,bd.BOOK_ID) AS Seq
			,bd.BOOK_CLASS_ID AS BookClassId
			,bd.BOOK_ID AS BookId
			,bd.BOOK_NAME AS BookName
			,COUNT(bd.BOOK_ID)AS Cnt
			,bc.BOOK_CLASS_NAME AS	BookClassName
	  FROM BOOK_DATA bd 
		JOIN BOOK_LEND_RECORD blr ON bd.BOOK_ID=blr.BOOK_ID
		JOIN BOOK_CLASS bc ON bd.BOOK_CLASS_ID=bc.BOOK_CLASS_ID
	  GROUP BY bd.BOOK_CLASS_ID,bd.BOOK_NAME,bd.BOOK_ID,bc.BOOK_CLASS_NAME
	  )AS table1
WHERE table1.Seq<4
ORDER BY BookClass;
/*5.請列出 2016, 2017, 2018, 2019 各書籍類別的借閱數量比較
Table：BOOK_LEND_RECORD*/
SELECT bc.BOOK_CLASS_ID AS ClassId,bc.BOOK_CLASS_NAME AS ClassName
	   ,SUM(blr.Cnt2016)AS Cnt2016,SUM(blr.Cnt2017)AS Cnt2017
	   ,SUM(blr.Cnt2018)AS Cnt2018,SUM(blr.Cnt2019)AS Cnt2019
FROM (SELECT BOOK_ID AS BookId
			,CASE 
				WHEN YEAR(LEND_DATE)=2016 THEN 1 ELSE 0
             END AS Cnt2016
			,CASE 
                WHEN YEAR(LEND_DATE)=2017 THEN 1 ELSE 0
             END AS Cnt2017
			,CASE 
                 WHEN YEAR(LEND_DATE)=2018 THEN 1 ELSE 0
             END AS Cnt2018
			,CASE 
				 WHEN YEAR(LEND_DATE)=2019 THEN 1 ELSE 0
             END AS Cnt2019
	  FROM BOOK_LEND_RECORD ) AS blr 
	  JOIN BOOK_DATA bd ON blr.BookId=bd.BOOK_ID
	  JOIN BOOK_CLASS bc ON bd.BOOK_CLASS_ID=bc.BOOK_CLASS_ID
GROUP BY bc.BOOK_CLASS_ID,bc.BOOK_CLASS_NAME
ORDER BY ClassId;

/*6.請使用 PIVOT 語法列出2016, 2017, 2018, 2019 各書籍類別的借閱數量比較
Table：BOOK_LEND_RECORD
Sample：同第五題*/
SELECT	 ClassId,ClassName
		,ISNULL([2016],0)AS [Cnt2016]
		,ISNULL([2017],0)AS[Cnt2017]
		,ISNULL([2018],0)AS[Cnt2018]
		,ISNULL([2019],0)AS[Cnt2019]
FROM	(SELECT bc.BOOK_CLASS_ID AS ClassId
				,bc.BOOK_CLASS_NAME AS ClassName
				,YEAR(blr.LEND_DATE) AS LEND_DATE
				,COUNT(bd.BOOK_ID)AS BookId
		 FROM	BOOK_CLASS bc 
				JOIN BOOK_DATA bd  ON bc.BOOK_CLASS_ID=bd.BOOK_CLASS_ID
				JOIN BOOK_LEND_RECORD blr ON bd.BOOK_ID=blr.BOOK_ID
		 GROUP BY bc.BOOK_CLASS_ID,bc.BOOK_CLASS_NAME,(blr.LEND_DATE))AS GroupByLendDate
PIVOT	( SUM(GroupByLendDate.BookId) For LEND_DATE
		  IN ([2016],[2017],[2018],[2019])) AS pvt
ORDER BY ClassId;


--如果PIVOT裡面要用COUNT(LEND_DATE)衍生資料表裡面的LEND_DATE就要換成YEAR(LEND_DATE)
--因為這樣會算到每一天一個BookId的借閱紀錄，但是如果有一個BookId在一天有兩次借閱 就只會算(COUNT)成一筆紀錄
--解法:PIVOT裡面改成SUM(BookId)就可以解決衍生 資料表裡面不論LEND_DATE取的是年度或是日的資料
--因為衍生資料表裡面取出來的是同一類別之中不同日期(年度或日的)的BookId借閱數量
--所以在PIVOT裡面對算完(COUNT)的BookId借閱數量作加總(SUM)就可以
--以年度GROUPBY(LEND_DATE):BookId在一年只會有一筆COUNT，以日GROUP BY(LEND_DATE):BookId在一年會有多筆COUNT


/*7.請查詢出李四的借書紀錄，其中包含書本ID、購書日期(yyyy/mm/dd)、借閱日期(yyyy/mm/dd)、書籍類別(id-name)、借閱人(id-cname(ename))、狀態(id-name)、購書金額
Table：BOOK_DATA、BOOK_LEND_RECORD、BOOK_CLASS、BOOK_CODE*/
SELECT	bd.BOOK_ID AS '書本ID'
		,CONVERT(VARCHAR(100),bd.BOOK_BOUGHT_DATE,111) AS '購書日期'
		,CONVERT(VARCHAR(100),blr.LEND_DATE,111)AS '借閱日期'
		,CONCAT(bc.BOOK_CLASS_ID,'-',bc.BOOK_CLASS_NAME)AS '書籍類別'
		,CONCAT(blr.KEEPER_ID,'-',M.USER_CNAME,'(',M.USER_ENAME,')')AS'借閱人'
		,CONCAT(bd.BOOK_STATUS,'-',bcode.CODE_NAME)AS'狀態'
		,CONCAT(REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,bd.BOOK_AMOUNT),1),'.00',''),'元')AS'購書金額'
FROM	BOOK_DATA bd
		JOIN BOOK_LEND_RECORD blr ON bd.BOOK_ID=blr.BOOK_ID 
		JOIN BOOK_CODE bcode ON bcode.CODE_ID=bd.BOOK_STATUS
		JOIN BOOK_CLASS bc ON bc.BOOK_CLASS_ID=bd.BOOK_CLASS_ID
		JOIN MEMBER_M m ON M.[USER_ID]=blr.[KEEPER_ID]
WHERE	M.USER_CNAME='李四'
ORDER BY bd.BOOK_ID DESC;
/*8.新增一筆借閱紀錄，借書人為李四，書本ID為2004，並修改借閱日期為2019/01/02
Sample：*/
BEGIN TRY
	BEGIN TRAN
	INSERT INTO dbo.BOOK_LEND_RECORD([BOOK_ID],[KEEPER_ID],[LEND_DATE],[CRE_DATE],[CRE_USR],[MOD_DATE],[MOD_USR])
	SELECT	bd.BOOK_ID,mm.[USER_ID],GETDATE(),GETDATE(),mm.[USER_ID],GETDATE(),mm.[USER_ID]
	FROM	MEMBER_M mm,BOOK_DATA bd
	WHERE	mm.USER_CNAME='李四' AND bd.BOOK_ID=2004;
	UPDATE dbo.BOOK_LEND_RECORD
	SET BOOK_LEND_RECORD.LEND_DATE='2019-01-02'
	FROM MEMBER_M mm
	 JOIN BOOK_LEND_RECORD blr ON mm.[USER_ID]=blr.KEEPER_ID
	WHERE mm.USER_CNAME='李四';
	COMMIT TRAN
END TRY
BEGIN CATCH
	SELECT ERROR_STATE()
	ROLLBACK TRAN
END CATCH


/*把李四借BOOK_ID=2004的書記錄刪除*/
DELETE FROM dbo.BOOK_LEND_RECORD 
WHERE KEEPER_ID IN (SELECT [USER_ID]
					FROM	MEMBER_M mm
					WHERE	mm.USER_CNAME='李四')
	  AND BOOK_ID=2004;

SELECT *
FROM	BOOK_LEND_RECORD blr
WHERE	KEEPER_ID ='李四'
	  AND BOOK_ID=2004;

/*9.請將題9新增的借閱紀錄(書本ID=2004)刪除*/
DELETE FROM BOOK_LEND_RECORD
	   WHERE	KEEPER_ID IN(SELECT [USER_ID]
							 FROM	MEMBER_M mm
							 WHERE mm.USER_CNAME='李四')
				AND BOOK_ID=2004;
