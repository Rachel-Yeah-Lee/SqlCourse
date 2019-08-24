--Workshop2
/*1.�C�X�C�ӭɾ\�H�C�~�ɮѼƶq�A�ḙ̀ɾ\�H�s���M�~�װ��Ƨ�
Table�GBOOK_LEND_RECORD�BMEMBER_M */
USE [GSSWEB]
GO
SELECT	KEEPER_ID AS KeeperId,M.USER_CNAME AS CName, M.USER_ENAME AS EName,YEAR(LR.LEND_DATE) AS BorrowYear,COUNT(KEEPER_ID) AS BorrowCnt
FROM	BOOK_LEND_RECORD AS LR JOIN MEMBER_M AS M
		ON KEEPER_ID = [USER_ID]
GROUP BY KEEPER_ID,M.USER_CNAME,M.USER_ENAME,YEAR(LEND_DATE)
ORDER BY KeeperId,YEAR(LR.LEND_DATE);
/*2.�C�X�̨��w�諸�ѫe���W(�ɾ\�ƶq�̦h�e���W)
Table�GBOOK_LEND_RECORD */
SELECT TOP(5)LR.BOOK_ID AS BookId,BD.BOOK_NAME AS BookName,COUNT(BD.BOOK_ID) AS QTY 
FROM BOOK_LEND_RECORD AS LR JOIN BOOK_DATA AS BD
	 ON LR.BOOK_ID = BD.BOOK_ID
GROUP BY LR.BOOK_ID,BD.BOOK_NAME
ORDER BY QTY DESC;
/*3.�H�@�u�C�X2019�~�C�@�u���y�ɾ\�Ѷq
Table�GBOOK_LEND_RECORD*/
SELECT  [Quarter],COUNT([Quarter]) AS Cnt
FROM (SELECT 
		CASE
			WHEN DATEPART(QUARTER,LEND_DATE)= 1 THEN '2019-01~2019-03'
			WHEN DATEPART(QUARTER,LEND_DATE)= 2 THEN '2019-04~2019-06'
			WHEN DATEPART(QUARTER,LEND_DATE)= 3 THEN '2019-07~2019-09'
			WHEN DATEPART(QUARTER,LEND_DATE)= 4 THEN '2019-10~2019-12'
		END AS [Quarter]
	  FROM BOOK_LEND_RECORD 
	  WHERE YEAR(LEND_DATE)=2019) AS LR
GROUP BY [Quarter]
ORDER BY [Quarter]


/*4.���X�C�Ӥ����ɾ\�ƶq�e�T�W�ѥ��μƶq
Table�GBOOK_LEND_RECORD�BBOOK_CLASS*/
SELECT table1.Seq,bc.BOOK_CLASS_NAME AS BookClass, table1.BookId,table1.BookName,table1.Cnt
FROM (SELECT ROW_NUMBER() OVER(PARTITION BY bd.BOOK_CLASS_ID ORDER BY COUNT(bd.BOOK_ID)DESC)AS Seq
			,bd.BOOK_CLASS_ID AS BookClassId,bd.BOOK_ID AS BookId
			,bd.BOOK_NAME AS BookName,COUNT(bd.BOOK_ID)AS Cnt
	  FROM BOOK_DATA bd JOIN BOOK_LEND_RECORD blr
	  ON bd.BOOK_ID=blr.BOOK_ID
	  GROUP BY bd.BOOK_CLASS_ID,bd.BOOK_NAME,bd.BOOK_ID) AS table1 JOIN BOOK_CLASS bc
	  ON bc.BOOK_CLASS_ID = table1.BookClassId
WHERE table1.Seq<4
ORDER BY BookClass;
/*5.�ЦC�X 2016, 2017, 2018, 2019 �U���y���O���ɾ\�ƶq���
Table�GBOOK_LEND_RECORD*/
SELECT bc.BOOK_CLASS_ID AS ClassId,bc.BOOK_CLASS_NAME AS ClassName,SUM(blr.Cnt2016)AS Cnt2016
	   ,SUM(blr.Cnt2017)AS Cnt2017,SUM(blr.Cnt2018)AS Cnt2018,SUM(blr.Cnt2019)AS Cnt2019
FROM (SELECT BOOK_ID AS BookId,CASE 
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
